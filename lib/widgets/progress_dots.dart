import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows "question X of N" as a row of pill dots — simple and readable for
/// kids who can't read numbers confidently yet. Matches the Figma spec's
/// 22x8 active pill / 8x8 inactive dot.
class ProgressDots extends StatelessWidget {
  final int total;
  final int currentIndex; // 0-based
  final Color activeColor;

  const ProgressDots({
    super.key,
    required this.total,
    required this.currentIndex,
    this.activeColor = AppColors.brandCoral,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : AppColors.paginationDotInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
