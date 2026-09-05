import 'package:flutter/material.dart';

/// The app's mascot artwork exported from Figma. Falls back gracefully if
/// the image asset is ever missing (e.g. mid-refactor).
class MascotWidget extends StatelessWidget {
  final double size;

  /// Which mascot pose to show. Defaults to the cheerful owl used on the
  /// Home screen; pass [wellDone] for the "Well Done!" screen's smiley pose.
  final bool wellDone;

  const MascotWidget({super.key, this.size = 220, this.wellDone = false});

  @override
  Widget build(BuildContext context) {
    final asset = wellDone
        ? 'assets/images/mascots/well_done_smiley.webp'
        : 'assets/images/mascots/home_owl.webp';
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.emoji_emotions_rounded,
        size: size,
        color: Colors.orange,
      ),
    );
  }
}
