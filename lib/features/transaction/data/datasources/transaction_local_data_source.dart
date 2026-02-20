import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<void> cacheTransactions(List<Transaction> transactions);
  Future<List<Transaction>> getCachedTransactions();
  Future<void> cacheBalance(double balance);
  Future<double> getCachedBalance();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String cachedTransactionsKey = 'CACHED_TRANSACTIONS';
  static const String cachedBalanceKey = 'CACHED_BALANCE';

  TransactionLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheTransactions(List<Transaction> transactions) async {
    try {
      final jsonList = transactions.map((t) => TransactionModel.toJson(t)).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(cachedTransactionsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<Transaction>> getCachedTransactions() async {
    final jsonString = sharedPreferences.getString(cachedTransactionsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw CacheException('Failed to get cached transactions: ${e.toString()}');
      }
    } else {
      return [];
    }
  }

  @override
  Future<void> cacheBalance(double balance) async {
    try {
      await sharedPreferences.setDouble(cachedBalanceKey, balance);
    } catch (e) {
      throw CacheException('Failed to cache balance: ${e.toString()}');
    }
  }

  @override
  Future<double> getCachedBalance() async {
    final balance = sharedPreferences.getDouble(cachedBalanceKey);
    if (balance != null) {
      return balance;
    } else {
      return 500.0; // Default balance
    }
  }
}
