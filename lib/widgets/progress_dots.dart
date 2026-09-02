import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows "question X of N" as a row of filled/unfilled dots — simple and
/// readable for kids who can't read numbers confidently yet.
class ProgressDots extends StatelessWidget {
  final int total;
  final int currentIndex; // 0-based

  const ProgressDots({super.key, required this.total, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i <= currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == currentIndex ? 16 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: filled ? AppColors.warmOrange : Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
