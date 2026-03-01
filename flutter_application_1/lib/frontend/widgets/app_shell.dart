import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onDashboard;
  final VoidCallback onTransactions;

  const AppShell({
    super.key,
    required this.child,
    required this.onDashboard,
    required this.onTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Humanity Budget')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Dashboard'),
              onTap: onDashboard,
            ),
            ListTile(
              title: const Text('Transactions'),
              onTap: onTransactions,
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}