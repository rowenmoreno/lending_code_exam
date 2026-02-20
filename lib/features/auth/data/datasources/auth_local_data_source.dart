import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String cachedUserKey = 'CACHED_USER';
  static const String isLoggedInKey = 'IS_LOGGED_IN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(User user) async {
    try {
      final jsonString = json.encode(UserModel.toJson(user));
      await sharedPreferences.setString(cachedUserKey, jsonString);
      await sharedPreferences.setBool(isLoggedInKey, true);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<User> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      } catch (e) {
        throw CacheException('Failed to get cached user: ${e.toString()}');
      }
    } else {
      throw CacheException('No cached user found');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedUserKey);
      await sharedPreferences.setBool(isLoggedInKey, false);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(isLoggedInKey) ?? false;
  }
}
