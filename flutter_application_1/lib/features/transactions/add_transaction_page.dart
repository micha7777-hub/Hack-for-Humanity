import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _isIncome = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Income'),
              value: _isIncome,
              onChanged: (v) => setState(() => _isIncome = v),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'title': _titleCtrl.text,
                    'amount': double.parse(_amountCtrl.text),
                    'category': _categoryCtrl.text,
                    'isIncome': _isIncome,
                  },
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