import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lending_code_exam/core/error/failures.dart';
import 'package:lending_code_exam/features/transaction/domain/entities/transaction.dart';
import 'package:lending_code_exam/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:lending_code_exam/features/transaction/domain/usecases/send_money_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late SendMoneyUseCase useCase;
  late MockTransactionRepository mockTransactionRepository;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    useCase = SendMoneyUseCase(mockTransactionRepository);
  });

  const tUserId = '1';
  const tAmount = 100.0;
  final tTimestamp = DateTime(2024, 1, 1);
  final tTransaction = Transaction(
    id: '1',
    userId: tUserId,
    amount: tAmount,
    timestamp: tTimestamp,
    status: TransactionStatus.success,
  );

  group('SendMoneyUseCase', () {
    test('should return Transaction when send money is successful', () async {
      // arrange
      when(() => mockTransactionRepository.sendMoney(
            userId: any(named: 'userId'),
            amount: any(named: 'amount'),
          )).thenAnswer((_) async => Right(tTransaction));

      // act
      final result = await useCase(userId: tUserId, amount: tAmount);

      // assert
      expect(result, Right(tTransaction));
      verify(() => mockTransactionRepository.sendMoney(
            userId: tUserId,
            amount: tAmount,
          )).called(1);
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return InsufficientBalanceFailure when amount is zero',
        () async {
      // act
      final result = await useCase(userId: tUserId, amount: 0);

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<InsufficientBalanceFailure>()),
        (_) => fail('Should return failure'),
      );
      verifyZeroInteractions(mockTransactionRepository);
    });

    test('should return InsufficientBalanceFailure when amount is negative',
        () async {
      // act
      final result = await useCase(userId: tUserId, amount: -100);

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<InsufficientBalanceFailure>()),
        (_) => fail('Should return failure'),
      );
      verifyZeroInteractions(mockTransactionRepository);
    });

    test('should return InsufficientBalanceFailure when balance is insufficient',
        () async {
      // arrange
      const tFailure = InsufficientBalanceFailure('Insufficient balance');
      when(() => mockTransactionRepository.sendMoney(
            userId: any(named: 'userId'),
            amount: any(named: 'amount'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(userId: tUserId, amount: tAmount);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockTransactionRepository.sendMoney(
            userId: tUserId,
            amount: tAmount,
          )).called(1);
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockTransactionRepository.sendMoney(
            userId: any(named: 'userId'),
            amount: any(named: 'amount'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(userId: tUserId, amount: tAmount);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockTransactionRepository.sendMoney(
            userId: tUserId,
            amount: tAmount,
          )).called(1);
      verifyNoMoreInteractions(mockTransactionRepository);
    });
  });
}
