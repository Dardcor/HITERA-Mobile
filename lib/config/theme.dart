import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HiteraColors {
  static const bgPrimary = Color(0xFF0A0A0F);
  static const bgSecondary = Color(0xFF111118);
  static const bgCard = Color(0xFF16161F);
  static const bgCardHover = Color(0xFF1E1E2A);

  static const border = Color(0xFF2A2A3A);
  static const borderFocus = Color(0xFF00C2FF);

  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF8888AA);
  static const textMuted = Color(0xFF555570);

  static const accentBlue = Color(0xFF00C2FF);
  static Color accentBlueDim = const Color(0xFF00C2FF).withValues(alpha: 0.15);
  static const accentGreen = Color(0xFF00E676);
  static Color accentGreenDim = const Color(0xFF00E676).withValues(alpha: 0.12);
  static const accentRed = Color(0xFFFF4D6D);
  static Color accentRedDim = const Color(0xFFFF4D6D).withValues(alpha: 0.12);
  static const accentYellow = Color(0xFFFFD60A);
  static Color accentYellowDim =
      const Color(0xFFFFD60A).withValues(alpha: 0.12);
}

class HiteraTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: HiteraColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: HiteraColors.accentBlue,
        secondary: HiteraColors.accentGreen,
        surface: HiteraColors.bgCard,
        error: HiteraColors.accentRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: HiteraColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: HiteraColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HiteraColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HiteraColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: HiteraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: HiteraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: HiteraColors.borderFocus),
        ),
        labelStyle: const TextStyle(
          color: HiteraColors.textMuted,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(color: HiteraColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: HiteraColors.border,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HiteraColors.bgCard,
        selectedItemColor: HiteraColors.accentBlue,
        unselectedItemColor: HiteraColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
