import 'package:flutter/material.dart';
import '../../backend/models/transaction_model.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  final List<TransactionModel> transactions;

  const TransactionsPage({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.transactions.length,
              itemBuilder: (context, index) {
                final tx = widget.transactions[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      tx.isIncome
                          ? Icons.arrow_upward   // 🟢 income
                          : Icons.arrow_downward, // 🔴 expense
                      color:
                          tx.isIncome ? Colors.green : Colors.red,
                    ),
                    title: Text(tx.title),
                    trailing: Text(
                      '\$${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            tx.isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(),
            ),
          );

          if (result != null) {
            setState(() {
              widget.transactions.add(result);
            });
          }
        },
      ),
    );
  }
}