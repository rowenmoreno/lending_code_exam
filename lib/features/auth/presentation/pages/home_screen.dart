import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../auth/presentation/widgets/wallet_balance_card.dart';
import '../../../auth/presentation/widgets/action_button.dart';
import '../../../transaction/presentation/bloc/transaction/transaction_bloc.dart';
import '../../../transaction/presentation/bloc/wallet/wallet_bloc.dart';
import '../../../transaction/presentation/pages/send_money_screen.dart';
import '../../../transaction/presentation/pages/transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load wallet balance
    context.read<WalletBloc>().add(LoadWalletBalance(widget.user.id));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const LoginScreen(),
                ),
              ),
              (route) => false,
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WalletBloc>().add(LoadWalletBalance(widget.user.id));
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Wallet Balance Card
                  const WalletBalanceCard(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          icon: Icons.send,
                          label: 'Send Money',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context.read<WalletBloc>(),
                                    ),
                                    BlocProvider.value(
                                      value: context.read<TransactionBloc>(),
                                    ),
                                  ],
                                  child:
                                      SendMoneyScreen(userId: widget.user.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.history,
                          label: 'Transactions',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<TransactionBloc>(),
                                  child: TransactionHistoryScreen(
                                      userId: widget.user.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
