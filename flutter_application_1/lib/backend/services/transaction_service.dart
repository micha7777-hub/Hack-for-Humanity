import '../../frontend/transactions/transaction_model.dart';

class TransactionService {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  void add(TransactionModel tx) {
    _transactions.add(tx);
  }

  double get income =>
      _transactions.where((t) => t.isIncome).fold(0, (a, b) => a + b.amount);

  double get expenses =>
      _transactions.where((t) => !t.isIncome).fold(0, (a, b) => a + b.amount);

  double get balance => income - expenses;
}