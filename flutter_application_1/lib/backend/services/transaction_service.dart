import 'package:flutter_application_1/frontend/transactions/transaction_model.dart';

class TransactionService {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  void addTransaction(TransactionModel tx) {
    _transactions.insert(0, tx);
  }

  void removeTransaction(TransactionModel tx) {
    _transactions.remove(tx);
  }
}