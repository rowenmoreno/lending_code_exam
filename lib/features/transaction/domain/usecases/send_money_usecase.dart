import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class SendMoneyUseCase {
  final TransactionRepository repository;

  SendMoneyUseCase(this.repository);

  Future<Either<Failure, Transaction>> call({
    required String userId,
    required double amount,
  }) async {
    if (amount <= 0) {
      return const Left(
        InsufficientBalanceFailure('Amount must be greater than 0'),
      );
    }
    return await repository.sendMoney(userId: userId, amount: amount);
  }
}
