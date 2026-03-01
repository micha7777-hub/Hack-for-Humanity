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
    final scheme = Theme.of(context).colorScheme;
    final txs = widget.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: txs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 56, color: scheme.primary),
                    const SizedBox(height: 12),
                    const Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap + to add your first income or expense.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: txs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = txs[index];

                  final isIncome = tx.isIncome;
                  final amountText = (isIncome ? '+' : '-') +
                      '\$${tx.amount.toStringAsFixed(2)}';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: CircleAvatar(
                      backgroundColor:
                          (isIncome ? Colors.green : Colors.red).withOpacity(0.12),
                      child: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      tx.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(tx.category),
                    trailing: Text(
                      amountText,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
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
              // insert newest on top
              widget.transactions.insert(0, newTx);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}