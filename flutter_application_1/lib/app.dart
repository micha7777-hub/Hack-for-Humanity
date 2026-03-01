import 'package:flutter/material.dart';

import 'backend/services/transaction_service.dart';
import 'frontend/dashboard/dashboard_page.dart';
import 'frontend/garden/garden_page.dart';
import 'frontend/goals/goals_page.dart';
import 'frontend/transactions/transactions_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int index = 0;

  // shared service
  final TransactionService service = TransactionService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Keep body pages alive
      body: IndexedStack(
        index: index,
        children: [
          DashboardPage(transactions: service.transactions),
          TransactionsPage(transactions: service.transactions),
          const GoalsPage(),
          const GardenPage(),
        ],
      ),

      // ✅ Fix “blank” nav colors by forcing selected/unselected styling
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFFF6FBF7),
          indicatorColor: scheme.primary.withOpacity(0.12),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final isSelected = states.contains(MaterialState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? scheme.primary : Colors.black54,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final isSelected = states.contains(MaterialState.selected);
            return IconThemeData(
              color: isSelected ? scheme.primary : Colors.black45,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Goals',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_florist_outlined),
              selectedIcon: Icon(Icons.local_florist),
              label: 'Garden',
            ),
          ],
        ),
      ),
    );
  }
}