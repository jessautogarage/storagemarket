// lib/config/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF00B14F);
  static const Color primaryDark = Color(0xFF00913F);
  static const Color secondary = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFFAFAFA);
  static const Color primaryText = Color(0xFF1A1A1A);
  static const Color secondaryText = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color inputBackground = Color(0xFFF8F8F8);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(0xFF00B14F, {
        50: Color(0xFFE0F2E9),
        100: Color(0xFFB3E0C8),
        200: Color(0xFF80CCA3),
        300: Color(0xFF4DB77E),
        400: Color(0xFF26A862),
        500: Color(0xFF00B14F),
        600: Color(0xFF00A047),
        700: Color(0xFF008E3D),
        800: Color(0xFF007D33),
        900: Color(0xFF005E22),
      }),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}