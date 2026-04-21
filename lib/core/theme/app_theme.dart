import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Jira / Atlassian Design System palette ────────────────
  // Light
  static const _lightScaffold = Color(0xFFF7F8F9); // N20 sunken
  static const _lightSurface = Color(0xFFFFFFFF); // N0 raised
  static const _lightSelected = Color(0xFFE9F2FF); // B50
  static const _lightBorder = Color(0xFFDFE1E6); // N40
  static const _lightBorderStrong = Color(0xFFC1C7D0); // N60
  static const _lightText = Color(0xFF172B4D); // N800 primary text
  static const _lightTextSubtle = Color(0xFF44546F); // N500
  static const _lightPlaceholder = Color(0xFF8993A4); // N200
  static const _lightIcon = Color(0xFF44546F); // N500

  // Dark
  static const _darkScaffold = Color(0xFF1D2125); // DN20 body
  static const _darkSurface = Color(0xFF22272B); // DN50 raised
  static const _darkSurfaceOverlay = Color(0xFF282E33); // DN70
  static const _darkSelected = Color(0xFF1C2B41); // B900 selected
  static const _darkBorder = Color(0xFF2C333A); // DN100
  static const _darkBorderStrong = Color(0xFF454F59); // DN300
  static const _darkText = Color(0xFFB6C2CF); // DN900 primary text
  static const _darkTextSubtle = Color(0xFF9FADBC); // DN700
  static const _darkPlaceholder = Color(0xFF7D8691); // DN500
  static const _darkIcon = Color(0xFF9FADBC); // DN700

  // Brand
  static const _brand = Color(0xFF0C66E4); // B400 primary
  static const _brandDark = Color(0xFF579DFF); // B200 dark-mode brand
  static const _success = Color(0xFF1F845A); // G500
  static const _successDark = Color(0xFF7EE2B8); // G300
  static const _errorLight = Color(0xFFC9372C); // R500
  static const _errorDark = Color(0xFFF87168); // R300

  // ─── Light theme ───────────────────────────────────────────
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _brand,
      onPrimary: Colors.white,
      secondary: _brand,
      onSecondary: Colors.white,
      tertiary: _success,
      onTertiary: Colors.white,
      error: _errorLight,
      onError: Colors.white,
      surface: _lightSurface,
      onSurface: _lightText,
      onSurfaceVariant: _lightTextSubtle,
      outline: _lightBorderStrong,
      outlineVariant: _lightBorder,
    ),
    scaffoldBackgroundColor: _lightScaffold,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: _lightScaffold,
      foregroundColor: _lightText,
      centerTitle: false,
      titleTextStyle: TextStyle(color: _lightText, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _lightBorder),
      ),
      color: _lightSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightText,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: _lightBorderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _brand,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _errorLight, width: 2),
      ),
      hintStyle: const TextStyle(color: _lightPlaceholder, fontWeight: FontWeight.w400),
      prefixIconColor: _lightIcon,
    ),
    dividerTheme: const DividerThemeData(color: _lightBorder, thickness: 1, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: _lightSurface,
      selectedColor: _lightSelected,
      checkmarkColor: _brand,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _lightText,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _brand,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: _lightBorderStrong),
    ),
    iconTheme: const IconThemeData(color: _lightIcon),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ─── Dark theme ────────────────────────────────────────────
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _brandDark,
      onPrimary: _darkScaffold,
      secondary: _brandDark,
      onSecondary: _darkScaffold,
      tertiary: _successDark,
      onTertiary: _darkScaffold,
      error: _errorDark,
      onError: _darkScaffold,
      surface: _darkSurface,
      onSurface: _darkText,
      onSurfaceVariant: _darkTextSubtle,
      outline: _darkBorderStrong,
      outlineVariant: _darkBorder,
    ),
    scaffoldBackgroundColor: _darkScaffold,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: _darkScaffold,
      foregroundColor: _darkText,
      centerTitle: false,
      titleTextStyle: TextStyle(color: _darkText, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _darkBorder),
      ),
      color: _darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandDark,
        foregroundColor: _darkScaffold,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkText,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: _darkBorderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _brandDark,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _brandDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _errorDark),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _errorDark, width: 2),
      ),
      hintStyle: const TextStyle(color: _darkPlaceholder, fontWeight: FontWeight.w400),
      prefixIconColor: _darkIcon,
    ),
    dividerTheme: const DividerThemeData(color: _darkBorder, thickness: 1, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurfaceOverlay,
      selectedColor: _darkSelected,
      checkmarkColor: _brandDark,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _darkText,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _brandDark,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: _darkBorderStrong),
    ),
    iconTheme: const IconThemeData(color: _darkIcon),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
