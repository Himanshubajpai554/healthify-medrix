import 'package:flutter/material.dart';

class AppTheme {
  // Brand Palette (Healthify Glassmorphism UI Design System)
  static const Color primaryTeal = Color(0xFF0D9488); // #0D9488 Primary
  static const Color primaryDarkTeal = Color(0xFF0F766E); // #0F766E Primary Dark
  static const Color primaryColor = primaryTeal;
  static const Color primaryDark = primaryDarkTeal;
  static const Color primaryDeep = primaryDarkTeal;
  static const Color primaryLight = Color(0xFFE6F4F1);
  static const Color primarySubtle = Color(0xFF5EEAD4);

  static const Color accentColor = Color(0xFF0284C7); // Teal/Blue accent
  static const Color accentLight = Color(0xFFF0F9FF);

  // Light Mode Colors
  static const Color backgroundColor = Color(0xFFF3FAF9); // #F3FAF9 Light Background
  static Color cardColor = Colors.white.withValues(alpha: 0.72);
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderFocused = primaryTeal;

  // Dark Mode Colors
  static const Color darkBackgroundColor = Color(0xFF061817); // #061817 Dark Background
  static Color darkCardColor = Colors.white.withValues(alpha: 0.045);
  static const Color darkTextPrimary = Colors.white;
  static Color darkTextSecondary = Colors.white.withValues(alpha: 0.55);
  static Color darkTextMuted = Colors.white.withValues(alpha: 0.38);
  static Color darkBorderLight = Colors.white.withValues(alpha: 0.085);

  // Warning & Legal Disclaimer Colors
  static const Color warningBg = Color(0xFFFFF1F2);
  static const Color warningBorder = Color(0xFFFECDD3);
  static const Color warningText = Color(0xFF9F1239);
  static const Color warningIcon = Color(0xFFE11D48);

  // Password Strength & Status Colors
  static const Color strengthWeak = Color(0xFFEF4444);
  static const Color strengthMedium = Color(0xFFF59E0B);
  static const Color strengthStrong = Color(0xFF10B981);

  // Light Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryDarkTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryTeal, primaryDarkTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFFE6F4F1), Color(0xFFF0F9FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dark Gradients
  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF0A2E2B), Color(0xFF061817)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme Data
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        primary: primaryTeal,
        secondary: accentColor,
        surface: Colors.white,
      ),
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.90),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryTeal, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryTeal.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: primaryTeal,
        secondary: accentColor,
        surface: const Color(0xFF0A2624),
        onSurface: darkTextPrimary,
      ),
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.075),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: darkTextMuted, fontSize: 14),
        labelStyle: TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        prefixIconColor: darkTextSecondary,
        suffixIconColor: darkTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: darkBorderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: darkBorderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryTeal, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryTeal.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}