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

  // Home screen's mode cards - picked to exactly match a category card's
  // color where one exists: Learn = Vehicles' blue, Guess = Fruits' red.
  static const modeLearnBlue = categoryVehicles;
  static const modeGuessRed = categoryFruits;

  // Draw (the tracing game) gets its own accent - a soft violet-blue
  // that doesn't collide with any existing category color, matching the
  // purple used throughout the standalone "Tiny Tracers" prototype this
  // was ported from.
  static const modeDrawPurple = Color(0xFF8B7BFF);

  // Puzzle has no game behind it yet - a quiet, deliberately muted tone
  // for a "Coming Soon" card so it doesn't compete with the two live ones.
  static const modePuzzleMuted = Color(0xFFB7AFC9);

  // Tracing-board tokens, matching the prototype's canvas palette: the
  // lane the child should stay inside, the dotted guide (unlit/lit), the
  // drawn stroke itself, and the start marker/demo-trail accent.
  static const traceTrack = Color(0xFFEDF0FF);
  static const traceDot = Color(0xFF8A97CC);
  static const traceHit = Color(0xFFFFC83D);
  static const traceStroke = modeDrawPurple;
  static const traceStart = Color(0xFFFF6B57);

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

  /// A static (always-heavy) ExtraBold instance of Baloo 2, for the
  /// handful of spots that need to read unmistakably bold: the Home
  /// title, header page titles, the Well Done heading, and the
  /// Let's Play!/Play Again CTA labels. (Google discontinued the
  /// original standalone "Baloo" typeface — it's no longer published
  /// anywhere — so this static instance is the reliable substitute:
  /// unlike the variable Baloo2 file above, it has no weight axis for
  /// a renderer to under-apply, so it always renders heavy.)
  static const boldHeadingFontFamily = 'BalooBold';

  /// Nunito is used for body text and button labels.
  static const bodyFontFamily = 'Nunito';

  static const double cardRadius = 24; // fruit/animal/vehicle/shape/color cards
  static const double categoryCardRadius = 28;
  static const double promptCardRadius = 28;
  static const double buttonRadius = 999; // pill
}
