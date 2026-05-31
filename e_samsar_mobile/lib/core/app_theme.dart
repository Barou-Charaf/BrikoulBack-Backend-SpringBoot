import 'package:flutter/material.dart';

class AppColors {
  // --- NOUVELLES COULEURS FIGMA ---
  static const primary = Color(0xFF1E2F97); // Bleu Indigo Figma
  static const primaryDark = Color(0xFF152272);
  static const accent = Color(0xFFFF9100); // Orange Figma

  // --- COMPATIBILITÉ (Pour corriger tes erreurs) ---
  // On fait pointer les anciens noms vers les nouvelles couleurs Figma
  static const secondary = accent; // L'ancien orange devient le orange Figma
  static const primaryContainer =
      Color(0xFF2A3FB1); // Un bleu légèrement plus clair pour les dégradés
  static const surfaceLow =
      Color(0xFFF1F5F9); // Un gris très clair pour les fonds de cartes

  // --- SURFACES ET TEXTES ---
  static const background = Color(0xFFF7FAFA);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF181C1D);
  static const textWhite = Color(0xFFFFFFFF);
  static const muted = Color(0xFF64748B);
  static const outline = Color(0xFFE2E8F0);

  // --- ÉTATS ---
  static const error = Color(0xFFBA1A1A);
  static const success = Color(0xFF2E7D32);
  static const whatsApp = Color(0xFF25D366);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textWhite,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(60),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size.fromHeight(56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
