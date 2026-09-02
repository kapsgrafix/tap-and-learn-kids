import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ConfettiBurst()),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MascotWidget(size: 200),
                  const SizedBox(height: 12),
                  const Text(
                    'Well Done!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You got ${widget.perfectCount} out of ${widget.total} right away! 🌟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 36),
                  PrimaryButton(
                    label: 'Play Again',
                    icon: Icons.refresh_rounded,
                    color: AppColors.grassGreen,
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
                    color: AppColors.skyBlueDark,
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
