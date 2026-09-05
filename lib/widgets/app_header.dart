import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The back-arrow + centered-title header used on every screen after
/// Home (Category Select, the Quiz screen and its Correct/Wrong states).
/// A fixed-size, invisible slot on the right mirrors the back button's
/// slot on the left so the title sits exactly in the middle of the row,
/// matching the Figma "Header" component (LeftSlot / title / RightSlot).
class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const AppHeader({super.key, required this.title, required this.onBack});

  static const double _slotSize = 26;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          SizedBox(
            width: _slotSize,
            height: _slotSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 24,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: onBack,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.headingFontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: _slotSize, height: _slotSize),
        ],
      ),
    );
  }
}
