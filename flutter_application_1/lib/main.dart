import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/game_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌱 WHITE + GREEN THEME
      theme: ThemeData(
        useMaterial3: true,

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  backgroundColor: Color(0xFFF6FBF7),
  selectedItemColor: Color(0xFF2E7D32),
  unselectedItemColor: Color(0xFF7A8A7F),
  showSelectedLabels: true,
  showUnselectedLabels: true,
  type: BottomNavigationBarType.fixed,
),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // deep green
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2E7D32),
          elevation: 0,
          centerTitle: true,
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFFF6FBF7), // soft green-white
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F8F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      home: const App(),
    );
  }
}