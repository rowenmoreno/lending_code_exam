import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lending_code_exam/core/error/failures.dart';
import 'package:lending_code_exam/features/auth/domain/entities/user.dart';
import 'package:lending_code_exam/features/auth/domain/repositories/auth_repository.dart';
import 'package:lending_code_exam/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tUsername = 'demo';
  const tPassword = 'password';
  const tUser = User(
    id: '1',
    username: 'demo',
    balance: 500.0,
  );

  group('LoginUseCase', () {
    test('should return User when login is successful', () async {
      // arrange
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      // act
      final result = await useCase(username: tUsername, password: tPassword);

      // assert
      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.login(
            username: tUsername,
            password: tPassword,
          )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthenticationFailure when credentials are invalid',
        () async {
      // arrange
      const tFailure = AuthenticationFailure('Invalid credentials');
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(username: tUsername, password: 'wrong');

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.login(
            username: tUsername,
            password: 'wrong',
          )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(username: tUsername, password: tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.login(
            username: tUsername,
            password: tPassword,
          )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
