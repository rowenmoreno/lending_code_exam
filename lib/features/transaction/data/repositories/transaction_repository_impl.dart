import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Transaction>> sendMoney({
    required String userId,
    required double amount,
  }) async {
    try {
      // Check if user has sufficient balance
      final currentBalance = await localDataSource.getCachedBalance();
      if (currentBalance < amount) {
        return Left(
          InsufficientBalanceFailure('Insufficient balance. Current balance: ₱${currentBalance.toStringAsFixed(2)}'),
        );
      }

      final transaction = await remoteDataSource.sendMoney(
        userId: userId,
        amount: amount,
      );

      // Update local balance
      final newBalance = currentBalance - amount;
      await localDataSource.cacheBalance(newBalance);

      // Cache the transaction
      final cachedTransactions = await localDataSource.getCachedTransactions();
      cachedTransactions.insert(0, transaction);
      await localDataSource.cacheTransactions(cachedTransactions);

      return Right(transaction);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions(userId: userId);
      await localDataSource.cacheTransactions(transactions);
      return Right(transactions);
    } on ServerException catch (e) {
      // Try to get cached transactions if remote fails
      try {
        final cachedTransactions = await localDataSource.getCachedTransactions();
        if (cachedTransactions.isNotEmpty) {
          return Right(cachedTransactions);
        }
        return Left(ServerFailure(e.message));
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } on NetworkException catch (e) {
      // Try to get cached transactions if network fails
      try {
        final cachedTransactions = await localDataSource.getCachedTransactions();
        if (cachedTransactions.isNotEmpty) {
          return Right(cachedTransactions);
        }
        return Left(NetworkFailure(e.message));
      } catch (_) {
        return Left(NetworkFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getUserBalance({
    required String userId,
  }) async {
    try {
      final balance = await localDataSource.getCachedBalance();
      return Right(balance);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get balance: ${e.toString()}'));
    }
  }
}
