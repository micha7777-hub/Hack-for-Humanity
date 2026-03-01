import 'package:flutter/material.dart';
import 'transaction_model.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.builder(
          itemCount: widget.transactions.length,
          itemBuilder: (context, index) {
            final tx = widget.transactions[index];
            return ListTile(
              leading: Icon(
                tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: tx.isIncome ? Colors.green : Colors.red,
              ),
              title: Text(tx.title),
              subtitle: Text(tx.category),
              trailing: Text('\$${tx.amount.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTx = await Navigator.push<TransactionModel>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );

          if (newTx != null) {
            setState(() {
              widget.transactions.insert(0, newTx);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}