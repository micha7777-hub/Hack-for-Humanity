import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../transactions/transaction_model.dart';

/// -------------------------
/// Helpers (Top-level)
/// -------------------------

List<DateTime> _last7Days() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 6));
  return List.generate(7, (i) => start.add(Duration(days: i)));
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Returns 7 values (oldest -> newest) for expenses only
List<double> _dailyExpensesLast7Days(List<TransactionModel> transactions) {
  final days = _last7Days();
  final totals = List<double>.filled(7, 0);

  for (final t in transactions) {
    if (t.isIncome) continue; // only expenses
    final d = DateTime(t.date.year, t.date.month, t.date.day);

    for (int i = 0; i < days.length; i++) {
      if (_isSameDay(d, days[i])) {
        totals[i] += t.amount;
        break;
      }
    }
  }
  return totals;
}

/// Returns 7 values (oldest -> newest) for end-of-day balance each day
List<double> _dailyBalanceLast7Days(List<TransactionModel> transactions) {
  final days = _last7Days();
  final balances = List<double>.filled(7, 0);

  for (int i = 0; i < days.length; i++) {
    final day = days[i];

    double incomeUpToDay = 0;
    double expensesUpToDay = 0;

    for (final t in transactions) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d.isAfter(day)) continue; // include on/before this day

      if (t.isIncome) {
        incomeUpToDay += t.amount;
      } else {
        expensesUpToDay += t.amount;
      }
    }

    balances[i] = incomeUpToDay - expensesUpToDay;
  }

  return balances;
}

double _maxOf(List<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

double _minOf(List<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);

double _niceTop(double maxY) => maxY <= 0 ? 10 : maxY * 1.25;
double _niceBottom(double minY) => minY >= 0 ? 0 : minY * 1.25;

/// -------------------------
/// Dashboard Page
/// -------------------------

class DashboardPage extends StatelessWidget {
  final List<TransactionModel> transactions;

  const DashboardPage({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final income = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final balance = income - expenses;
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final days = _last7Days();
    final dailyExpenses = _dailyExpensesLast7Days(transactions);
    final dailyBalance = _dailyBalanceLast7Days(transactions);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Logo + Title (centered)
                Image.asset(
                  'assets/images/wallet-plant.png',
                  height: 200, // bigger logo
                ),
                const SizedBox(height: 18),
                const Text(
                  'Debt Free Me',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 32),

                // Summary cards
                isWide
                    ? Row(
                        children: [
                          _summaryCard(
                            'Income',
                            money.format(income),
                            Icons.arrow_upward,
                            const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 16),
                          _summaryCard(
                            'Expenses',
                            money.format(expenses),
                            Icons.arrow_downward,
                            const Color(0xFF66BB6A),
                          ),
                          const SizedBox(width: 16),
                          _summaryCard(
                            'Balance',
                            money.format(balance),
                            Icons.account_balance,
                            const Color(0xFF2E7D32),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _summaryCard(
                            'Income',
                            money.format(income),
                            Icons.arrow_upward,
                            const Color(0xFF2E7D32),
                          ),
                          const SizedBox(height: 16),
                          _summaryCard(
                            'Expenses',
                            money.format(expenses),
                            Icons.arrow_downward,
                            const Color(0xFF66BB6A),
                          ),
                          const SizedBox(height: 16),
                          _summaryCard(
                            'Balance',
                            money.format(balance),
                            Icons.account_balance,
                            const Color(0xFF2E7D32),
                          ),
                        ],
                      ),

                const SizedBox(height: 24),

                // Expenses graph
                _chartCard(
                  title: 'Daily Expenses (Last 7 Days)',
                  child: _lineChart(
                    days: days,
                    values: dailyExpenses,
                    isMoney: true,
                    lineColor: const Color(0xFF66BB6A),
                    minY: 0,
                    maxY: _niceTop(_maxOf(dailyExpenses)),
                  ),
                ),

                const SizedBox(height: 16),

                // Balance graph
                _chartCard(
                  title: 'Daily Balance (Last 7 Days)',
                  child: _lineChart(
                    days: days,
                    values: dailyBalance,
                    isMoney: true,
                    lineColor: const Color(0xFF2E7D32),
                    minY: _niceBottom(_minOf(dailyBalance)),
                    maxY: _niceTop(_maxOf(dailyBalance)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// -------------------------
  /// UI Widgets
  /// -------------------------

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color.withOpacity(0.9), size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 260, child: child),
          ],
        ),
      ),
    );
  }

  Widget _lineChart({
    required List<DateTime> days,
    required List<double> values,
    required bool isMoney,
    required Color lineColor,
    required double minY,
    required double maxY,
  }) {
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final spots =
        List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                final idx = s.x.toInt().clamp(0, 6);
                final dayLabel = DateFormat('EEE').format(days[idx]);
                final valLabel =
                    isMoney ? money.format(s.y) : s.y.toStringAsFixed(2);

                return LineTooltipItem(
                  '$dayLabel\n$valLabel',
                  const TextStyle(fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i > 6) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('EEE').format(days[i])),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: (maxY - minY) == 0 ? 1 : (maxY - minY) / 5,
              getTitlesWidget: (value, meta) {
                final label = isMoney
                    ? '\$${value.toStringAsFixed(0)}'
                    : value.toStringAsFixed(0);
                return Text(label);
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: lineColor,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}