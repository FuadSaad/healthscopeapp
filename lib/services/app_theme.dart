import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized theme management for HealthScope BD.
/// Provides dark/light mode switching and theme-aware color palette.
class AppTheme {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
      await prefs.setBool('isDarkMode', false);
    } else {
      themeMode.value = ThemeMode.dark;
      await prefs.setBool('isDarkMode', true);
    }
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Light Theme ──
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.light,
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF3B82F6),
          surface: const Color(0xFFF0FDF4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0FDF4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      );

  // ── Dark Theme ──
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF3B82F6),
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
        ),
      );
}

/// Theme-aware color palette. Instantiate with context:
///   `final c = AppColors(context);`
class AppColors {
  final bool dark;
  AppColors(BuildContext context) : dark = AppTheme.isDark(context);

  // ── Backgrounds ──
  Color get bg => dark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4);
  Color get bgSecondary => dark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5);
  Color get headerGradient1 => dark ? const Color(0xFF064E3B) : const Color(0xFF10B981);
  Color get headerGradient2 => dark ? const Color(0xFF0F172A) : const Color(0xFF059669);
  Color get headerGradient3 => dark ? const Color(0xFF1E1B4B) : const Color(0xFF34D399);

  // ── Glass effects ──
  Color get glassBg => dark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.8);
  Color get glassBgStrong => dark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.9);
  Color get glassBorder => dark ? Colors.white.withOpacity(0.1) : const Color(0xFFD1FAE5);
  Color get glassBorderSubtle => dark ? Colors.white.withOpacity(0.06) : const Color(0xFFA7F3D0).withOpacity(0.4);

  // ── Text ──
  Color get textPrimary => dark ? Colors.white : const Color(0xFF1E293B);
  Color get textSecondary => dark ? Colors.white.withOpacity(0.5) : const Color(0xFF64748B);
  Color get textTertiary => dark ? Colors.white.withOpacity(0.35) : const Color(0xFF94A3B8);
  Color get textOnAccent => Colors.white;

  // ── Cards ──
  Color get cardBg => dark ? Colors.white.withOpacity(0.05) : Colors.white;
  Color get cardBorder => dark ? Colors.white.withOpacity(0.08) : const Color(0xFFD1FAE5);
  Color get cardShadow => dark ? Colors.black.withOpacity(0.3) : const Color(0xFF10B981).withOpacity(0.06);

  // ── Inputs ──
  Color get inputBg => dark ? Colors.white.withOpacity(0.06) : const Color(0xFFECFDF5);
  Color get inputBorder => dark ? Colors.white.withOpacity(0.08) : const Color(0xFFA7F3D0);
  Color get inputHint => dark ? Colors.white.withOpacity(0.3) : const Color(0xFF6EE7B7);

  // ── Chips / Buttons ──
  Color get chipBg => dark ? Colors.white.withOpacity(0.05) : const Color(0xFFECFDF5);
  Color get chipBorder => dark ? Colors.white.withOpacity(0.1) : const Color(0xFFD1FAE5);

  // ── Dividers & Borders ──
  Color get divider => dark ? Colors.white.withOpacity(0.06) : const Color(0xFFD1FAE5);

  // ── Nav Bar ──
  Color get navBg => dark ? const Color(0xFF1E293B) : Colors.white;
  Color get navInactive => dark ? Colors.white.withOpacity(0.3) : const Color(0xFF6EE7B7);
  Color get navBorder => dark ? Colors.white.withOpacity(0.06) : const Color(0xFFD1FAE5);
  Color get navShadow => dark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06);

  // ── Glow / Orbs ──
  double get glowOpacity => dark ? 0.25 : 0.15;
  double get shadowSpread => dark ? 5.0 : 2.0;

  // ── Map ──
  String get mapTileUrl => dark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  // ── Dropdown ──
  Color get dropdownBg => dark ? const Color(0xFF1E293B) : Colors.white;

  // ── Accent Colors (same for both themes) ──
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDark = Color(0xFF1D4ED8);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF6D28D9);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);
  static const Color red = Color(0xFFEF4444);
  static const Color redDark = Color(0xFFDC2626);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color green = Color(0xFF16A34A);
  static const Color slate = Color(0xFF64748B);
}
