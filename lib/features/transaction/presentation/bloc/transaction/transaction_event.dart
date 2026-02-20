part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class SendMoneyRequested extends TransactionEvent {
  final String userId;
  final double amount;

  const SendMoneyRequested({
    required this.userId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, amount];
}

class LoadTransactions extends TransactionEvent {
  final String userId;

  const LoadTransactions(this.userId);

  @override
  List<Object> get props => [userId];
}
