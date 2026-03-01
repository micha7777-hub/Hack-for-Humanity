import 'package:flutter/material.dart';

import 'frontend/dashboard/dashboard_page.dart';
import 'frontend/transactions/transactions_page.dart';
import 'frontend/goals/goals_page.dart';
import 'frontend/garden/garden_page.dart';
import 'frontend/insights/insights_page.dart';

import 'backend/services/transaction_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int index = 0;

  final TransactionService service = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: IndexedStack(
        index: index,
        children: [
          DashboardPage(transactions: service.transactions),
          TransactionsPage(transactions: service.transactions),
          const GoalsPage(),
          const GardenPage(),
          InsightsPage(transactions: service.transactions), // ✅ AI tab
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: 'Garden'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI'), // ✅
        ],
      ),
    );
  }
}