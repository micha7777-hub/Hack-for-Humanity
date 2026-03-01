
import 'package:flutter/material.dart';
import '../../backend/models/transaction_model.dart';

class DashboardPage extends StatelessWidget {
  final List<TransactionModel> transactions;

  const DashboardPage({
    super.key,
    required this.transactions,
  });

  @override
Widget build(BuildContext context) {
  double income = 0;
  double expenses = 0;

  for (final t in transactions) {
    if (t.isIncome) {
      income += t.amount;
    } else {
      expenses += t.amount;
    }
  }

  final balance = income - expenses;

  return Padding(
    padding: const EdgeInsets.all(16),
    child: GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _summaryCard('Income', income, Colors.green),
        _summaryCard('Expenses', expenses, Colors.red),
        _summaryCard('Balance', balance, Colors.blue),
      ],
    ),
  );
}
Widget _summaryCard(String title, double amount, Color color) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
}