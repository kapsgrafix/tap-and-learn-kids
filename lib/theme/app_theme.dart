import 'package:flutter/material.dart';

/// Brand tokens pulled directly from the "Smart Kids" Figma file
/// (Tap & Learn tab). Keep these in sync with Figma's named variables —
/// the names in the comments match the Figma variable names.
class AppColors {
  AppColors._();

  // bg/*
  static const bgYellow = Color(0xFFFFF8E6);
  static const bgCard = Colors.white;

  // text/*
  static const textPrimary = Color(0xFF2B2640);
  static const textSecondary = Color(0xFF8B849C);
  static const textInverse = Colors.white;

  // brand/*
  static const brandCoral = Color(0xFFFF6B4A);
  static const brandTeal = Color(0xFF2EC4B6);

  // category/* — also used as each category's card/prompt-card color
  static const categoryFruits = Color(0xFFE43A35);
  static const categoryAnimals = Color(0xFFFF8A3D);
  static const categoryColors = Color(0xFFFE6FB6);
  static const categoryVehicles = Color(0xFF3B78C8);
  static const categoryShapes = Color(0xFF7ED956);

  // mascot badge gradient
  static const mascotGradientTop = Color(0xFFFF8766);
  static const mascotGradientBottom = Color(0xFFE8542E);

  // misc
  static const paginationDotInactive = Color(0xFFD9CC9E);
  static const correctGreen = categoryShapes;
  static const wrongRed = categoryFruits;
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.brandCoral,
      scaffoldBackgroundColor: AppColors.bgYellow,
      fontFamily: 'Nunito',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }

  /// Baloo 2 is used for headings, titles, and category labels.
  static const headingFontFamily = 'Baloo2';

  /// Nunito is used for body text and button labels.
  static const bodyFontFamily = 'Nunito';

  static const double cardRadius = 24; // fruit/animal/vehicle/shape/color cards
  static const double categoryCardRadius = 28;
  static const double promptCardRadius = 28;
  static const double buttonRadius = 999; // pill
}
