import '../../domain/entities/transaction.dart';

class TransactionModel {
  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      status: _statusFromString(json['status'] as String?),
    );
  }

  static Map<String, dynamic> toJson(Transaction transaction) {
    return transaction.toJson();
  }

  static TransactionStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'pending':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.success;
    }
  }

  static Transaction fromEntity(Transaction transaction) {
    return transaction;
  }
}
