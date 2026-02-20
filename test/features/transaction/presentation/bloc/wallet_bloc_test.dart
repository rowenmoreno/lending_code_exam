import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lending_code_exam/core/error/failures.dart';
import 'package:lending_code_exam/features/transaction/domain/usecases/get_user_balance_usecase.dart';
import 'package:lending_code_exam/features/transaction/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUserBalanceUseCase extends Mock
    implements GetUserBalanceUseCase {}

void main() {
  late WalletBloc walletBloc;
  late MockGetUserBalanceUseCase mockGetUserBalanceUseCase;

  setUp(() {
    mockGetUserBalanceUseCase = MockGetUserBalanceUseCase();
    walletBloc = WalletBloc(
      getUserBalanceUseCase: mockGetUserBalanceUseCase,
    );
  });

  tearDown(() {
    walletBloc.close();
  });

  const tUserId = '1';
  const tBalance = 500.0;

  group('WalletBloc', () {
    test('initial state should be WalletInitial', () {
      expect(walletBloc.state, equals(const WalletInitial()));
    });

    group('LoadWalletBalance', () {
      blocTest<WalletBloc, WalletState>(
        'should emit [WalletLoading, WalletLoaded] when loading balance is successful',
        build: () {
          when(() => mockGetUserBalanceUseCase(
                userId: any(named: 'userId'),
              )).thenAnswer((_) async => const Right(tBalance));
          return walletBloc;
        },
        act: (bloc) => bloc.add(const LoadWalletBalance(tUserId)),
        expect: () => [
          const WalletLoading(),
          const WalletLoaded(balance: tBalance, isBalanceVisible: true),
        ],
        verify: (_) {
          verify(() => mockGetUserBalanceUseCase(userId: tUserId)).called(1);
        },
      );

      blocTest<WalletBloc, WalletState>(
        'should emit [WalletLoading, WalletError] when loading balance fails',
        build: () {
          when(() => mockGetUserBalanceUseCase(
                userId: any(named: 'userId'),
              )).thenAnswer(
            (_) async => const Left(
              CacheFailure('Failed to load balance'),
            ),
          );
          return walletBloc;
        },
        act: (bloc) => bloc.add(const LoadWalletBalance(tUserId)),
        expect: () => [
          const WalletLoading(),
          const WalletError('Failed to load balance'),
        ],
        verify: (_) {
          verify(() => mockGetUserBalanceUseCase(userId: tUserId)).called(1);
        },
      );
    });

    group('ToggleBalanceVisibility', () {
      blocTest<WalletBloc, WalletState>(
        'should toggle balance visibility from visible to hidden',
        build: () => walletBloc,
        seed: () => const WalletLoaded(
          balance: tBalance,
          isBalanceVisible: true,
        ),
        act: (bloc) => bloc.add(const ToggleBalanceVisibility()),
        expect: () => [
          const WalletLoaded(
            balance: tBalance,
            isBalanceVisible: false,
          ),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'should toggle balance visibility from hidden to visible',
        build: () => walletBloc,
        seed: () => const WalletLoaded(
          balance: tBalance,
          isBalanceVisible: false,
        ),
        act: (bloc) => bloc.add(const ToggleBalanceVisibility()),
        expect: () => [
          const WalletLoaded(
            balance: tBalance,
            isBalanceVisible: true,
          ),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'should not emit any state when current state is not WalletLoaded',
        build: () => walletBloc,
        seed: () => const WalletInitial(),
        act: (bloc) => bloc.add(const ToggleBalanceVisibility()),
        expect: () => [],
      );
    });
  });
}
