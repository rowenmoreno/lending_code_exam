import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/wallet/wallet_bloc.dart';
import '../widgets/transaction_result_bottom_sheet.dart';
import '../widgets/available_balance_info_card.dart';

class SendMoneyScreen extends StatefulWidget {
  final String userId;

  const SendMoneyScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleSendMoney() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      context.read<TransactionBloc>().add(
            SendMoneyRequested(
              userId: widget.userId,
              amount: amount,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            TransactionResultBottomSheet.show(
              context: context,
              isSuccess: true,
              message: 'You have successfully sent ₱${NumberFormat('#,##0.00').format(state.transaction.amount)}',
              transactionId: state.transaction.id,
              onDone: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.pop(context); // Go back to home
                // Refresh wallet balance
                context.read<WalletBloc>().add(LoadWalletBalance(widget.userId));
              },
            );
          } else if (state is TransactionError) {
            TransactionResultBottomSheet.show(
              context: context,
              isSuccess: false,
              message: state.message,
              onDone: () {
                Navigator.pop(context); // Close bottom sheet
              },
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TransactionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  const AvailableBalanceInfoCard(),
                  const SizedBox(height: 32),

                  // Amount input
                  Text(
                    'Enter Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    enabled: !isLoading,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₱',
                      prefixStyle: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(24),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Please enter a valid amount';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Quick amount buttons
                  Text(
                    'Quick Amounts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickAmountChip(
                        amount: 100,
                        onTap: () => _amountController.text = '100',
                        enabled: !isLoading,
                      ),
                      _QuickAmountChip(
                        amount: 200,
                        onTap: () => _amountController.text = '200',
                        enabled: !isLoading,
                      ),
                      _QuickAmountChip(
                        amount: 500,
                        onTap: () => _amountController.text = '500',
                        enabled: !isLoading,
                      ),
                      _QuickAmountChip(
                        amount: 1000,
                        onTap: () => _amountController.text = '1000',
                        enabled: !isLoading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Submit button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSendMoney,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send Money',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;
  final bool enabled;

  const _QuickAmountChip({
    required this.amount,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('₱${NumberFormat('#,##0').format(amount)}'),
      onPressed: enabled ? onTap : null,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: enabled ? Colors.black87 : Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
