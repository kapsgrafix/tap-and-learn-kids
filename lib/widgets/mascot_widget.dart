import 'package:flutter/material.dart';

/// The app's mascot/branding artwork. Falls back gracefully if the image
/// asset is ever missing (e.g. mid-refactor).
class MascotWidget extends StatelessWidget {
  final double size;

  /// Which pose to show. Defaults to the Home screen's logo; pass
  /// [wellDone] for the "Well Done!" screen's celebratory emoji.
  final bool wellDone;

  const MascotWidget({super.key, this.size = 220, this.wellDone = false});

  @override
  Widget build(BuildContext context) {
    final asset = wellDone
        ? 'assets/images/mascots/result_emoji.webp'
        : 'assets/images/mascots/home_logo.webp';
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
