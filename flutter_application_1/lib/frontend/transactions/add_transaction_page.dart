import 'package:flutter/material.dart';
import 'transaction_model.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
  
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String category = 'General';
  bool isIncome = false;
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (picked != null) {
    setState(() => selectedDate = picked);
  }
}

  void submit() {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (title.isEmpty || amount == null) return;

    final tx = TransactionModel(
      title: title,
      amount: amount,
      isIncome: isIncome,
      category: category,
      date: DateTime.now(),
    );

    Navigator.pop(context, tx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                DropdownMenuItem(value: 'Salary', child: Text('Salary')),
              ],
              onChanged: (v) => setState(() => category = v ?? 'General'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            SwitchListTile(
              title: const Text('Income?'),
              value: isIncome,
              onChanged: (v) => setState(() => isIncome = v),
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                    ),
                     ),
                     TextButton(
                      onPressed: pickDate,
                      child: const Text('Pick Date'),
                      ),
                      ],
                      ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}