import 'package:flutter/material.dart';

class TransactionResultBottomSheet extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final String? transactionId;
  final VoidCallback onDone;

  const TransactionResultBottomSheet({
    super.key,
    required this.isSuccess,
    required this.message,
    this.transactionId,
    required this.onDone,
  });

  static void show({
    required BuildContext context,
    required bool isSuccess,
    required String message,
    String? transactionId,
    required VoidCallback onDone,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: !isSuccess,
      enableDrag: !isSuccess,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionResultBottomSheet(
        isSuccess: isSuccess,
        message: message,
        transactionId: transactionId,
        onDone: onDone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            size: 64,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isSuccess ? 'Transaction Successful!' : 'Transaction Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (transactionId != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Transaction ID: $transactionId',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isSuccess ? 'Done' : 'Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}
