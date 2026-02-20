part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class LoadWalletBalance extends WalletEvent {
  final String userId;

  const LoadWalletBalance(this.userId);

  @override
  List<Object> get props => [userId];
}

class ToggleBalanceVisibility extends WalletEvent {
  const ToggleBalanceVisibility();
}
