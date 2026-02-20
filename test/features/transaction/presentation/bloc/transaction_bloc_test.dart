import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lending_code_exam/core/error/failures.dart';
import 'package:lending_code_exam/features/transaction/domain/entities/transaction.dart';
import 'package:lending_code_exam/features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'package:lending_code_exam/features/transaction/domain/usecases/send_money_usecase.dart';
import 'package:lending_code_exam/features/transaction/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSendMoneyUseCase extends Mock implements SendMoneyUseCase {}

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

void main() {
  late TransactionBloc transactionBloc;
  late MockSendMoneyUseCase mockSendMoneyUseCase;
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;

  setUp(() {
    mockSendMoneyUseCase = MockSendMoneyUseCase();
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    transactionBloc = TransactionBloc(
      sendMoneyUseCase: mockSendMoneyUseCase,
      getTransactionsUseCase: mockGetTransactionsUseCase,
    );
  });

  tearDown(() {
    transactionBloc.close();
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
  final tTransactionList = [tTransaction];

  group('TransactionBloc', () {
    test('initial state should be TransactionInitial', () {
      expect(transactionBloc.state, equals(const TransactionInitial()));
    });

    group('SendMoneyRequested', () {
      blocTest<TransactionBloc, TransactionState>(
        'should emit [TransactionLoading, TransactionSuccess] when send money is successful',
        build: () {
          when(() => mockSendMoneyUseCase(
                userId: any(named: 'userId'),
                amount: any(named: 'amount'),
              )).thenAnswer((_) async => Right(tTransaction));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(
          const SendMoneyRequested(userId: tUserId, amount: tAmount),
        ),
        expect: () => [
          const TransactionLoading(),
          TransactionSuccess(tTransaction),
        ],
        verify: (_) {
          verify(() => mockSendMoneyUseCase(
                userId: tUserId,
                amount: tAmount,
              )).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'should emit [TransactionLoading, TransactionError] when send money fails',
        build: () {
          when(() => mockSendMoneyUseCase(
                userId: any(named: 'userId'),
                amount: any(named: 'amount'),
              )).thenAnswer(
            (_) async => const Left(
              InsufficientBalanceFailure('Insufficient balance'),
            ),
          );
          return transactionBloc;
        },
        act: (bloc) => bloc.add(
          const SendMoneyRequested(userId: tUserId, amount: tAmount),
        ),
        expect: () => [
          const TransactionLoading(),
          const TransactionError('Insufficient balance'),
        ],
        verify: (_) {
          verify(() => mockSendMoneyUseCase(
                userId: tUserId,
                amount: tAmount,
              )).called(1);
        },
      );
    });

    group('LoadTransactions', () {
      blocTest<TransactionBloc, TransactionState>(
        'should emit [TransactionListLoading, TransactionListLoaded] when loading transactions is successful',
        build: () {
          when(() => mockGetTransactionsUseCase(
                userId: any(named: 'userId'),
              )).thenAnswer((_) async => Right(tTransactionList));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions(tUserId)),
        expect: () => [
          const TransactionListLoading(),
          TransactionListLoaded(tTransactionList),
        ],
        verify: (_) {
          verify(() => mockGetTransactionsUseCase(userId: tUserId)).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'should emit [TransactionListLoading, TransactionListError] when loading transactions fails',
        build: () {
          when(() => mockGetTransactionsUseCase(
                userId: any(named: 'userId'),
              )).thenAnswer(
            (_) async => const Left(
              ServerFailure('Failed to load transactions'),
            ),
          );
          return transactionBloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions(tUserId)),
        expect: () => [
          const TransactionListLoading(),
          const TransactionListError('Failed to load transactions'),
        ],
        verify: (_) {
          verify(() => mockGetTransactionsUseCase(userId: tUserId)).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'should emit [TransactionListLoading, TransactionListLoaded] with empty list',
        build: () {
          when(() => mockGetTransactionsUseCase(
                userId: any(named: 'userId'),
              )).thenAnswer((_) async => const Right([]));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions(tUserId)),
        expect: () => [
          const TransactionListLoading(),
          const TransactionListLoaded([]),
        ],
        verify: (_) {
          verify(() => mockGetTransactionsUseCase(userId: tUserId)).called(1);
        },
      );
    });
  });
}
