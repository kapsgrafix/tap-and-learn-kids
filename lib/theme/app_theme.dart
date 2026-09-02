import 'package:flutter/material.dart';

/// Central place for the "Tap & Learn Kids" brand palette and shared
/// styling. Kept bright, warm, and high-contrast for young children.
class AppColors {
  AppColors._();

  static const sunnyYellow = Color(0xFFFFC93C);
  static const warmOrange = Color(0xFFFF8A3D);
  static const skyBlue = Color(0xFF5D9CEC);
  static const skyBlueDark = Color(0xFF3C78C8);
  static const grassGreen = Color(0xFF7ED957);
  static const bubblePink = Color(0xFFFF6FB5);
  static const cream = Color(0xFFFFF8E7);
  static const inkText = Color(0xFF3B3B3B);
  static const correctGreen = Color(0xFF43A047);
  static const wrongRed = Color(0xFFE53935);
  static const cardShadow = Color(0x33000000);

  static const List<Color> categoryPalette = [
    bubblePink,
    skyBlue,
    grassGreen,
    warmOrange,
    Color(0xFFB388FF), // soft purple
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.warmOrange,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.inkText,
        displayColor: AppColors.inkText,
      ),
    );
  }

  static const double cardRadius = 28;
  static const double buttonRadius = 32;
}
