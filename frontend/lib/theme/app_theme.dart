import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primarySalmon = Color(0xFFFF6B6B);
  static const Color accentTeal = Color(0xFF4ECDC4);
  static const Color background = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  // For compatibility with older code if any
  static const Color primaryColor = primarySalmon;
  static const Color secondaryColor = accentTeal;
  static const Color darkBg = background;
  static const Color cardBg = surfaceColor;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primarySalmon,
    scaffoldBackgroundColor: background,
    cardColor: surfaceColor,
    colorScheme: const ColorScheme.dark(
      primary: primarySalmon,
      secondary: accentTeal,
      surface: surfaceColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySalmon,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}
