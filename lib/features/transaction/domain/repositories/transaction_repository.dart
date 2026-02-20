import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Transaction>> sendMoney({
    required String userId,
    required double amount,
  });
  
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
  });
  
  Future<Either<Failure, double>> getUserBalance({
    required String userId,
  });
}
