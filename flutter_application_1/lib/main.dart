import 'package:flutter/material.dart';
import 'features/transactions/transactions_page.dart';
void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Humanity Budget',
      debugShowCheckedModeBanner: false,
      home: const TransactionsPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text(
          'Budgeting App – Hack for Humanity',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
