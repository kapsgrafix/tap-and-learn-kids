import 'package:flutter/material.dart';
import '../screens/privacy_policy_screen.dart';
import '../theme/app_theme.dart';

/// The bottom-left counterpart to [SoundToggleButton]: opens the full-page
/// Privacy Policy screen. Drop this inside a [Stack] on the Home screen
/// (it positions itself), the same way [SoundToggleButton] is used.
class PrivacyPolicyButton extends StatelessWidget {
  const PrivacyPolicyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      bottom: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          );
        },
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.privacy_tip_outlined,
            size: 30,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
