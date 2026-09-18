import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';

/// One tile in the Learn screen's 3-column word grid: the illustration on
/// top, the word itself on a colored strip below (unlike the quiz's
/// OptionCard, this mode is about learning the word, so the label is
/// always shown). Tapping plays the word's narration; [isActive] highlights
/// whichever card is currently sounding out.
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(item.imageAsset, fit: BoxFit.contain),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: categoryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volume_up_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.headingFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
