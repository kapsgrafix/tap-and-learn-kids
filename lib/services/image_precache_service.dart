import 'package:flutter/material.dart';
import '../data/categories_data.dart';

/// Preloads every bundled illustration into Flutter's in-memory image
/// cache so screens never show a blank flash while a picture decodes for
/// the first time.
///
/// All artwork ships inside the APK (there is no `Image.network` and no
/// INTERNET permission anywhere in this app), so this never touches the
/// network — it just does the one-time local decode work up front, right
/// after the app opens, instead of lazily the first time each screen is
/// visited.
Future<void> precacheAllGameImages(BuildContext context) async {
  final paths = <String>{
    'assets/images/mascots/home_owl.webp',
    'assets/images/mascots/well_done_smiley.webp',
  };
  for (final category in gameCategories) {
    if (category.iconAsset.isNotEmpty) paths.add(category.iconAsset);
    for (final item in category.items) {
      paths.add(item.imageAsset);
    }
  }

  await Future.wait([
    for (final path in paths)
      precacheImage(AssetImage(path), context).catchError((_) {
        // A missing/placeholder asset should never block the game from
        // starting — the widgets that use it already fall back gracefully.
      }),
  ]);
}
