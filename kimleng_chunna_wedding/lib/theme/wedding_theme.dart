import 'package:flutter/material.dart';

class WeddingColors {
  static const Color primary = Color(0xFF8B4513); // Saddle Brown
  static const Color secondary = Color(0xFFD2B48C); // Tan
  static const Color accent = Color(0xFFF5DEB3); // Wheat
  static const Color background = Color(0xFFFEFEFE); // Off White
  static const Color textPrimary = Color(0xFF2C1810); // Dark Brown
  static const Color textSecondary = Color(0xFF6B5B47); // Medium Brown
  static const Color gold = Color(0xFFFFD700); // Gold
  static const Color white = Color(0xFFFFFFFF); // Pure White
  static const Color lightGray = Color(0xFFF8F8F8); // Light Gray
  static const Color darkBlue = Color(0xFF135288); // Black
}

class WeddingTextStyles {
  static TextStyle get heading1 => const TextStyle(
        fontFamily: 'Moulpali',
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: WeddingColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get heading2 => const TextStyle(
        fontFamily: 'Koulen',
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: WeddingColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get heading3 => const TextStyle(
        fontFamily: 'Koulen',
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: WeddingColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: 'Moulpali',
        fontSize: 16,
        color: WeddingColors.textSecondary,
        height: 1.6,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'Moulpali',
        fontSize: 18,
        color: WeddingColors.textSecondary,
        height: 1.6,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: 'Moulpali',
        fontSize: 14,
        color: WeddingColors.textSecondary,
        fontStyle: FontStyle.italic,
        height: 1.5,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: 'Dangrek',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: WeddingColors.white,
      );

  static TextStyle get small => const TextStyle(
        fontFamily: 'Moulpali',
        fontSize: 12,
        color: WeddingColors.textSecondary,
        height: 1.4,
      );
  static TextStyle get smallKhmer => const TextStyle(
        fontFamily: 'Moulpali',
        fontSize: 12,
        color: WeddingColors.textSecondary,
        height: 1.4,
      );

  // Kept for backward compatibility - now uses Moulpali font
  static TextStyle bayon({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Moulpali',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? WeddingColors.textPrimary,
      height: height,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}

class WeddingTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WeddingColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        headlineLarge: WeddingTextStyles.heading1,
        headlineMedium: WeddingTextStyles.heading2,
        headlineSmall: WeddingTextStyles.heading3,
        bodyLarge: WeddingTextStyles.bodyLarge,
        bodyMedium: WeddingTextStyles.body,
        bodySmall: WeddingTextStyles.caption,
        labelLarge: WeddingTextStyles.button,
        labelSmall: WeddingTextStyles.small,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WeddingColors.primary,
          foregroundColor: WeddingColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: WeddingTextStyles.button,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFFB88527)),
        trackColor: WidgetStateProperty.all(WeddingColors.lightGray),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: WeddingColors.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: WeddingColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: WeddingColors.primary, width: 2),
        ),
        labelStyle: WeddingTextStyles.body,
        hintStyle: WeddingTextStyles.caption,
      ),
    );
  }
}
