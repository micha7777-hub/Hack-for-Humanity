import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.builder(
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );

          if (result != null) {
            setState(() {
              transactions.add(
                TransactionModel(
                  id: DateTime.now().toString(),
                  title: result['title'],
                  amount: result['amount'],
                  date: DateTime.now(),
                  category: 'General',
                  isIncome: result['isIncome'],
                ),
              );
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}