import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../transaction/presentation/bloc/wallet/wallet_bloc.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withAlpha((0.7 * 255).toInt()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    if (state is WalletLoaded)
                      IconButton(
                        icon: Icon(
                          state.isBalanceVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.read<WalletBloc>().add(
                                const ToggleBalanceVisibility(),
                              );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state is WalletLoading)
                  const CircularProgressIndicator(
                    color: Colors.white,
                  )
                else if (state is WalletError)
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                else if (state is WalletLoaded)
                  Text(
                    state.isBalanceVisible
                        ? '₱${NumberFormat('#,##0.00').format(state.balance)}'
                        : '₱******',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    '₱0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
