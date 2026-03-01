import 'package:flutter/material.dart';

import 'frontend/dashboard/dashboard_page.dart';
import 'frontend/transactions/transactions_page.dart';
import 'backend/services/transaction_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int index = 0;

  // shared service
  final TransactionService service = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: index == 0
          ? DashboardPage(transactions: service.transactions)
          : TransactionsPage(transactions: service.transactions),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}