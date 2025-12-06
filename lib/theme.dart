import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  final base = ThemeData.dark();
  const accent = Color(0xFFE91E63); // pink heart accent

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      secondary: accent,
    ),
    scaffoldBackgroundColor: const Color(0xFF101018),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181822),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
    ),
    cardColor: const Color(0xFF1D1D28),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF282838),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}