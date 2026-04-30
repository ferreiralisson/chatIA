import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF97CE4C);
  static const Color darkBackground = Color(0xFF060B18);
  static const Color surfaceColor = Color(0xFF0F3460);
  static const Color cardColor = Color(0x1EFFFFFF);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF060B18),
      Color(0xFF0B1730),
      Color(0xFF0E1E3D),
      Color(0xFF060B18),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEFF4FF),
      Color(0xFFE2EEF9),
      Color(0xFFECF5E8),
      Color(0xFFEFF4FF),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryGreen,
        surface: Color(0x1EFFFFFF),
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x1EFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x14FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: primaryGreen.withValues(alpha: 0.7), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: Colors.white54,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: primaryGreen,
        surface: Colors.white.withValues(alpha: 0.65),
        onPrimary: Colors.black,
        onSurface: const Color(0xFF111827),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: primaryGreen.withValues(alpha: 0.9),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.55),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: primaryGreen.withValues(alpha: 0.7), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIconColor: Colors.black38,
      ),
    );
  }
}
