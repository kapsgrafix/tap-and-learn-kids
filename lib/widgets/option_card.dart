import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';
import 'shape_painter.dart';

enum OptionState { idle, correct, wrong, disabled }

/// One of the four tappable answer cards in the 2x2 grid. Shows only the
/// item's picture/shape/color (never its written label) so the child has
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
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: isCorrectTapped
                      ? AppColors.correctGreen
                      : isWrongTapped
                          ? AppColors.wrongRed
                          : Colors.transparent,
                  width: 5,
                ),
                boxShadow: const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(child: _buildVisual()),
              ),
            ),
            if (isCorrectTapped) _buildBadge(Icons.check_rounded, AppColors.correctGreen),
            if (isWrongTapped) _buildBadge(Icons.close_rounded, AppColors.wrongRed),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual() {
    switch (item.visualKind) {
      case VisualKind.emoji:
        return Text(item.emoji!, style: const TextStyle(fontSize: 64));
      case VisualKind.shape:
        return ShapeIcon(shape: item.shape!, color: item.color!, size: 84);
      case VisualKind.color:
        return Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12, width: 2),
          ),
        );
    }
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
