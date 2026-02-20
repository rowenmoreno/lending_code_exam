part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionSuccess extends TransactionState {
  final Transaction transaction;

  const TransactionSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionListLoading extends TransactionState {
  const TransactionListLoading();
}

class TransactionListLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionListLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionListError extends TransactionState {
  final String message;

  const TransactionListError(this.message);

  @override
  List<Object?> get props => [message];
}
