import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Palette ───────────────────────────────────────────────
  // Warm neutrals — think boutique hotel, not SaaS dashboard
  static const _primary = Color(0xFF1A1A1A); // near-black
  static const _primaryDark = Color(0xFFF5F0EB); // warm cream for dark mode
  static const _accent = Color(0xFFC9A96E); // muted gold
  static const _error = Color(0xFFBF4040); // soft red

  // ─── Light theme ───────────────────────────────────────────
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accent,
      primary: _primary,
      secondary: _accent,
      error: _error,
      brightness: Brightness.light,
      surface: const Color(0xFFFAF8F5), // warm white
      onPrimary: const Color(0xFFFAF8F5),
      onSurface: const Color(0xFF1A1A1A),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F0EB), // light beige
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Color(0xFFF5F0EB),
      foregroundColor: Color(0xFF1A1A1A),
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E0D6)),
      ),
      color: const Color(0xFFFAF8F5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: const Color(0xFFF5F0EB),
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAF8F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6CEC4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _error, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF9C917F),
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: const Color(0xFF9C917F),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE8E0D6),
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF5F0EB),
      selectedColor: _accent.withAlpha(30),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: Color(0xFFE8E0D6)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF3D3D3D)),
  );

  // ─── Dark theme ────────────────────────────────────────────
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accent,
      primary: _primaryDark,
      secondary: _accent,
      error: const Color(0xFFE06060),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      onPrimary: const Color(0xFF1A1A1A),
      onSurface: const Color(0xFFEDE8E2),
    ),
    scaffoldBackgroundColor: const Color(0xFF141414),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Color(0xFF141414),
      foregroundColor: Color(0xFFEDE8E2),
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFFEDE8E2),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2E2E2E)),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: Color(0xFFEDE8E2), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEDE8E2), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE06060)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE06060), width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF6B6560),
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: const Color(0xFF6B6560),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2E2E2E),
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF242424),
      selectedColor: _accent.withAlpha(40),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: Color(0xFF3A3A3A)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFB5AEA4)),
  );
}
