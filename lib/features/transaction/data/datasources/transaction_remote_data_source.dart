import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionRemoteDataSource {
  Future<Transaction> sendMoney({
    required String userId,
    required double amount,
  });

  Future<List<Transaction>> getTransactions({
    required String userId,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  TransactionRemoteDataSourceImpl({required this.client});

  @override
  Future<Transaction> sendMoney({
    required String userId,
    required double amount,
  }) async {
    try {
      // Using JSONPlaceholder to simulate API call
      final response = await client.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        
        // Create transaction from response
        return Transaction(
          id: jsonResponse['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          amount: amount,
          timestamp: DateTime.now(),
          status: TransactionStatus.success,
        );
      } else {
        throw ServerException('Failed to send money: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<List<Transaction>> getTransactions({
    required String userId,
  }) async {
    try {
      // Using JSONPlaceholder to simulate API call
      final response = await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        
        // Convert posts to transactions for demo
        return jsonList.take(10).map((json) {
          final Map<String, dynamic> item = json as Map<String, dynamic>;
          return Transaction(
            id: item['id']?.toString() ?? '',
            userId: userId,
            amount: (item['id'] as num? ?? 0).toDouble() * 10 + 50, // Simulated amounts
            timestamp: DateTime.now().subtract(
              Duration(days: (item['id'] as num? ?? 0).toInt()),
            ),
            status: TransactionStatus.success,
          );
        }).toList();
      } else {
        throw ServerException('Failed to get transactions: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
}
