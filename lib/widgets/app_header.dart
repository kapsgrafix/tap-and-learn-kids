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
  static const double _tapTargetSize = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          SizedBox(
            width: _slotSize,
            height: _slotSize,
            // The visible icon stays pinned to its small Figma-accurate
            // slot (so the title still lands dead-center), but the actual
            // tap target overflows that slot up to Material's full 48x48
            // touch size - the icon was easy to visually miss-tap before.
            child: OverflowBox(
              minWidth: _tapTargetSize,
              maxWidth: _tapTargetSize,
              minHeight: _tapTargetSize,
              maxHeight: _tapTargetSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 24,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: onBack,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.boldHeadingFontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w800,
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
