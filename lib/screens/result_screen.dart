import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/sound_toggle_button.dart';
import 'game_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameCategory category;
  final int perfectCount;
  final int total;

  const ResultScreen({
    super.key,
    required this.category,
    required this.perfectCount,
    required this.total,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.playSfx('win_fanfare.mp3');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ConfettiBurst()),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MascotWidget(size: 200, wellDone: true),
                  const SizedBox(height: 12),
                  const Text(
                    'Well Done!',
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You got ${widget.perfectCount} out of ${widget.total} right!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  PrimaryButton(
                    label: 'Play Again',
                    icon: Icons.refresh_rounded,
                    color: AppColors.categoryShapes,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => GameScreen(category: widget.category)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Home',
                    icon: Icons.home_rounded,
                    color: AppColors.brandTeal,
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                  ),
                ],
              ),
            ),
            // Figma's BottomBar sound toggle: bottom-right on every screen.
            const SoundToggleButton(),
          ],
        ),
      ),
    );
  }
}
