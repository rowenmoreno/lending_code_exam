import '../../domain/entities/user.dart';

class UserModel {
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 500.0,
    );
  }

  static Map<String, dynamic> toJson(User user) {
    return user.toJson();
  }

  static User fromEntity(User user) {
    return user;
  }
}
