part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final double balance;
  final bool isBalanceVisible;

  const WalletLoaded({
    required this.balance,
    this.isBalanceVisible = true,
  });

  WalletLoaded copyWith({
    double? balance,
    bool? isBalanceVisible,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }

  @override
  List<Object?> get props => [balance, isBalanceVisible];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
