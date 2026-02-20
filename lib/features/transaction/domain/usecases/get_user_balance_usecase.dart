import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class GetUserBalanceUseCase {
  final TransactionRepository repository;

  GetUserBalanceUseCase(this.repository);

  Future<Either<Failure, double>> call({
    required String userId,
  }) async {
    return await repository.getUserBalance(userId: userId);
  }
}
