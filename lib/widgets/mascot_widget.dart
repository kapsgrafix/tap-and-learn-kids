import 'package:flutter/material.dart';

/// Ollie the Owl, the app's mascot. Falls back gracefully if the image
/// asset is ever missing (e.g. mid-refactor).
class MascotWidget extends StatelessWidget {
  final double size;
  const MascotWidget({super.key, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mascot_ollie.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.emoji_emotions_rounded,
        size: size,
        color: Colors.orange,
      ),
    );
  }
}
