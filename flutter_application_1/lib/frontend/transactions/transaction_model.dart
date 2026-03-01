class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;

  TransactionModel({
    String? id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    DateTime? date,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        date = date ?? DateTime.now();

        Map<String, dynamic> toJson() {
  return {
    "title": title,
    "category": category,
    "amount": amount,
    "isIncome": isIncome,
    "date": date.toIso8601String(),
  };
}
}