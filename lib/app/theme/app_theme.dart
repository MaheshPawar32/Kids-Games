import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color ink = Color(0xFF25345B);
  static const Color violet = Color(0xFF8B73E8);
  static const Color canvas = Color(0xFFF4F8FF);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: violet,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 27,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF65718D),
          fontSize: 14,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
