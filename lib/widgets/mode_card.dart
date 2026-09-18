import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pulsing_scale.dart';

/// One of the two big Home-screen choices — "Learn the word" or "Guess the
/// word" — matching Figma's 160x173 "Category Card" component on the Home
/// screen (distinct from the category-select grid's own CategoryCard).
class ModeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final Color color;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.color,
    required this.onTap,
  });

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return PulsingScale(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.95),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 160,
            height: 173,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(AppTheme.categoryCardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(widget.iconAsset, fit: BoxFit.contain),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: AppTheme.boldHeadingFontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textInverse,
                    height: 32 / 30,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontFamily: AppTheme.headingFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textInverse,
                    height: 18 / 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
