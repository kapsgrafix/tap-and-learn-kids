import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';

enum OptionState { idle, correct, wrong, disabled }

/// One of the four tappable answer cards in the 2x2 grid. Shows only the
/// item's illustrated artwork (never its written label) so the child has
/// to actually recognize it from the word + sound prompt above.
class OptionCard extends StatelessWidget {
  final GameItem item;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionCard({super.key, required this.item, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWrongTapped = state == OptionState.wrong;
    final isCorrectTapped = state == OptionState.correct;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isCorrectTapped ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: isCorrectTapped
                      ? AppColors.correctGreen
                      : isWrongTapped
                          ? AppColors.wrongRed
                          : Colors.transparent,
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
            if (isCorrectTapped) _buildBadge(Icons.check_rounded, AppColors.correctGreen),
            if (isWrongTapped) _buildBadge(Icons.close_rounded, AppColors.wrongRed),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Positioned(
      top: -10,
      right: -10,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
