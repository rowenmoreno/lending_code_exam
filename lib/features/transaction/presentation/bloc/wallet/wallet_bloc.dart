import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/get_user_balance_usecase.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetUserBalanceUseCase getUserBalanceUseCase;

  WalletBloc({
    required this.getUserBalanceUseCase,
  }) : super(const WalletInitial()) {
    on<LoadWalletBalance>(_onLoadWalletBalance);
    on<ToggleBalanceVisibility>(_onToggleBalanceVisibility);
  }

  Future<void> _onLoadWalletBalance(
    LoadWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    
    final result = await getUserBalanceUseCase(userId: event.userId);

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (balance) => emit(WalletLoaded(balance: balance)),
    );
  }

  void _onToggleBalanceVisibility(
    ToggleBalanceVisibility event,
    Emitter<WalletState> emit,
  ) {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;
      emit(currentState.copyWith(
        isBalanceVisible: !currentState.isBalanceVisible,
      ));
    }
  }
}
