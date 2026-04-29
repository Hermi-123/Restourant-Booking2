import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra Premium Color Palette
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF1C1F26);
  static const Color primarySalmon = Color(0xFFFF6B6B);
  static const Color secondaryMint = Color(0xFF4ECDC4);
  static const Color accentGold = Color(0xFFFFD93D);
  
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFADB5BD);

  // Glassmorphism effect simulation colors
  static Color glassColor = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primarySalmon,
    colorScheme: const ColorScheme.dark(
      primary: primarySalmon,
      secondary: secondaryMint,
      surface: surface,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySalmon,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primarySalmon.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );

  // Shared UI Components (Abstracted for "Amazing UI")
  static BoxDecoration glassDecoration({double blur = 10, double opacity = 0.05}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
    );
  }

  static BoxDecoration gradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [primarySalmon, Color(0xFFFF8E8E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
