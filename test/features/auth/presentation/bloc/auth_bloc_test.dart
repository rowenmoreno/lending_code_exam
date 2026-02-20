import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lending_code_exam/core/error/failures.dart';
import 'package:lending_code_exam/features/auth/domain/entities/user.dart';
import 'package:lending_code_exam/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lending_code_exam/features/auth/domain/usecases/login_usecase.dart';
import 'package:lending_code_exam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lending_code_exam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tUsername = 'demo';
  const tPassword = 'password';
  const tUser = User(
    id: '1',
    username: 'demo',
    balance: 500.0,
  );

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when login is successful',
        build: () {
          when(() => mockLoginUseCase(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => const Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginRequested(username: tUsername, password: tPassword),
        ),
        expect: () => [
          const AuthLoading(),
          const Authenticated(tUser),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase(
                username: tUsername,
                password: tPassword,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when login fails',
        build: () {
          when(() => mockLoginUseCase(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer(
            (_) async => const Left(
              AuthenticationFailure('Invalid credentials'),
            ),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginRequested(username: tUsername, password: 'wrong'),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError('Invalid credentials'),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase(
                username: tUsername,
                password: 'wrong',
              )).called(1);
        },
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Unauthenticated] when logout is successful',
        build: () {
          when(() => mockLogoutUseCase()).thenAnswer(
            (_) async => const Right(null),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => mockLogoutUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when logout fails',
        build: () {
          when(() => mockLogoutUseCase()).thenAnswer(
            (_) async => const Left(CacheFailure('Failed to logout')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError('Failed to logout'),
        ],
        verify: (_) {
          verify(() => mockLogoutUseCase()).called(1);
        },
      );
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when user is logged in',
        build: () {
          when(() => mockGetCurrentUserUseCase()).thenAnswer(
            (_) async => const Right(tUser),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          const AuthLoading(),
          const Authenticated(tUser),
        ],
        verify: (_) {
          verify(() => mockGetCurrentUserUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Unauthenticated] when user is not logged in',
        build: () {
          when(() => mockGetCurrentUserUseCase()).thenAnswer(
            (_) async => const Left(CacheFailure('No cached user')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => mockGetCurrentUserUseCase()).called(1);
        },
      );
    });
  });
}
