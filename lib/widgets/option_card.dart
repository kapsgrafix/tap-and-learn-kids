import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';

enum OptionState { idle, correct, wrong, disabled }

/// One of the four tappable answer cards in the 2x2 grid. Shows only the
/// item's illustrated artwork (never its written label) so the child has
/// to actually recognize it from the word + sound prompt above.
///
/// A wrong tap is intentionally gentle: no red border, no cross icon —
/// just a small, calm "Wrong" tag in the quiz's own category color,
/// matching the Figma spec exactly. A correct tap gets a friendly green
/// checkmark badge instead, and the other (un-tapped) cards fade slightly
/// once an answer has been picked.
class OptionCard extends StatelessWidget {
  final GameItem item;
  final OptionState state;
  final Color categoryColor;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.item,
    required this.state,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrectTapped = state == OptionState.correct;
    final isWrongTapped = state == OptionState.wrong;
    final isFaded = state == OptionState.disabled;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isCorrectTapped ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: isFaded ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(
                    color: isCorrectTapped ? AppColors.correctGreen : Colors.transparent,
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(item.imageAsset, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              if (isCorrectTapped) _buildCorrectBadge(),
              if (isWrongTapped) _buildWrongTag(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorrectBadge() {
    return Positioned(
      top: -18,
      right: -18,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.correctGreen,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildWrongTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: categoryColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Text(
        'Wrong',
        style: TextStyle(
          fontFamily: AppTheme.bodyFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: categoryColor,
        ),
      ),
    );
  }
}
