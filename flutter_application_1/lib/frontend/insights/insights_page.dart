import 'package:flutter/material.dart';
import '../../backend/services/insights_service.dart';
import '../transactions/transaction_model.dart';

const String baseUrl = 'http://localhost:3001';

class InsightsPage extends StatefulWidget {
  final List<TransactionModel> transactions;
  const InsightsPage({super.key, required this.transactions});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    final txJson = widget.transactions.map((tx) => tx.toJson()).toList();
    data = InsightsService.fetchInsights(txJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Insights")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final resp = snap.data ?? {};

          // ✅ insights could be nested or top-level
          final Map<String, dynamic> insights =
              (resp["insights"] is Map<String, dynamic>)
                  ? (resp["insights"] as Map<String, dynamic>)
                  : resp;

          // ✅ tips could be called "suggestions" or "tips" (or missing)
          final tipsRaw = resp["suggestions"] ?? resp["tips"] ?? [];
          final List<String> tips = (tipsRaw is List)
              ? tipsRaw.map((e) => e.toString()).toList()
              : <String>[];

          // numbers (safe)
          final weeklyChange = (insights["weeklySpendingChangePct"] is num)
              ? (insights["weeklySpendingChangePct"] as num).toDouble()
              : 0.0;

          final projectedMonthSpend = (insights["projectedMonthSpend"] is num)
              ? (insights["projectedMonthSpend"] as num).toDouble()
              : 0.0;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                "Financial Snapshot",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  title: const Text("Weekly Spending Change"),
                  subtitle: Text("${weeklyChange.toStringAsFixed(2)}%"),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text("Projected Monthly Spend"),
                  subtitle:
                      Text("\$${projectedMonthSpend.toStringAsFixed(2)}"),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                "5 AI-Generated Actionable Tips",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              if (tips.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No tips returned yet. (Backend response is missing 'suggestions'/'tips')",
                    ),
                  ),
                )
              else
                ...tips.take(5).map(
                      (tip) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(tip),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}