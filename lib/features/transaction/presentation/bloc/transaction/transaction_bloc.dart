import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/send_money_usecase.dart';
import '../../../domain/usecases/get_transactions_usecase.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final SendMoneyUseCase sendMoneyUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionBloc({
    required this.sendMoneyUseCase,
    required this.getTransactionsUseCase,
  }) : super(const TransactionInitial()) {
    on<SendMoneyRequested>(_onSendMoneyRequested);
    on<LoadTransactions>(_onLoadTransactions);
  }

  Future<void> _onSendMoneyRequested(
    SendMoneyRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    
    final result = await sendMoneyUseCase(
      userId: event.userId,
      amount: event.amount,
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) => emit(TransactionSuccess(transaction)),
    );
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionListLoading());
    
    final result = await getTransactionsUseCase(userId: event.userId);

    result.fold(
      (failure) => emit(TransactionListError(failure.message)),
      (transactions) => emit(TransactionListLoaded(transactions)),
    );
  }
}
