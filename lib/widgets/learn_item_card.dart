import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';

/// One tile in the Learn screen's 3-column word grid: just the illustration
/// while idle. Tapping plays the word's narration and, while it sounds out
/// ([isActive]), the whole card fills with the category color and shows the
/// word with a speaker icon on top of it.
class LearnItemCard extends StatelessWidget {
  final GameItem item;
  final Color categoryColor;
  final bool isActive;
  final VoidCallback onTap;

  const LearnItemCard({
    super.key,
    required this.item,
    required this.categoryColor,
    required this.isActive,
    required this.onTap,
  });

  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isActive ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isActive ? categoryColor : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(item.imageAsset, fit: BoxFit.contain),
              ),
              // While the word is sounding out, the whole card becomes a
              // solid color-fill with the word (and a speaker icon) on top —
              // a big, unmistakable "this one!" moment for a young child.
              AnimatedOpacity(
                opacity: isActive ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  color: categoryColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded, size: 26, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.headingFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
