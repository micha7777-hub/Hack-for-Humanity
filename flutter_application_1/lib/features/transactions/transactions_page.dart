import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TransactionModel> transactions = [
      TransactionModel(
        id: '1',
        title: 'Groceries',
        amount: 120,
        date: DateTime.now(),
        category: 'Food',
        isIncome: false,
      ),
      TransactionModel(
        id: '2',
        title: 'Paycheck',
        amount: 2000,
        date: DateTime.now(),
        category: 'Salary',
        isIncome: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            leading: Icon(
              tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: tx.isIncome ? Colors.green : Colors.red,
            ),
            title: Text(tx.title),
            subtitle: Text(tx.category),
            trailing: Text(
              '\$${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: tx.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}