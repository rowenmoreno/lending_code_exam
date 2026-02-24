import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      // Using JSONPlaceholder for demo - simulating authentication
      // In production, this would be a real auth endpoint
      final response = await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        // Simple authentication logic for demo
        if (username == 'demo' && password == 'password') {
          return User(
            id: jsonResponse['id']?.toString() ?? '1',
            username: username,
            balance: 500.0, // Initial balance
          );
        } else {
          throw AuthenticationException('Invalid username or password');
        }
      } else {
        throw ServerException('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
}
