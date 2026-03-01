import 'package:flutter/material.dart';
import '../../backend/models/transaction_model.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  bool isIncome = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            SwitchListTile(
              title: const Text('Income'),
              value: isIncome,
              onChanged: (v) => setState(() => isIncome = v),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  TransactionModel(
                    id: DateTime.now().toString(),
                    title: titleCtrl.text,
                    amount: double.parse(amountCtrl.text),
                    isIncome: isIncome,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}