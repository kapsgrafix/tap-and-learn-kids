import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../services/image_precache_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home_game_tile.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/privacy_policy_button.dart';
import '../widgets/sound_toggle_button.dart';
import 'category_select_screen.dart';
import 'tracing_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kick off decoding every bundled illustration once, right when the
    // app opens, so later screens never show a pop-in/blank flash while a
    // picture loads for the first time. Purely local — no network involved.
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      precacheAllGameImages(context);
    }
  }

  void _openCategorySelect(GameMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CategorySelectScreen(mode: mode)),
    );
  }

  void _openDraw() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TracingHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // The "Nimble Kids" wordmark is baked into this logo
                  // artwork itself, so there's no separate title text here.
                  const MascotWidget(size: 160),
                  const Text(
                    'Tap, Learn & Play!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandCoral,
                    ),
                  ),
                  const SizedBox(height: 28),
                  HomeGameTile(
                    icon: Icons.quiz_rounded,
                    title: 'Guess',
                    subtitle: 'Guess the word',
                    color: AppColors.modeGuessRed,
                    onTap: () => _openCategorySelect(GameMode.guess),
                  ),
                  const SizedBox(height: 14),
                  HomeGameTile(
                    icon: Icons.brush_rounded,
                    title: 'Draw',
                    subtitle: 'Trace shapes & numbers',
                    color: AppColors.modeDrawPurple,
                    onTap: _openDraw,
                  ),
                  const SizedBox(height: 14),
                  const HomeGameTile(
                    icon: Icons.extension_rounded,
                    title: 'Puzzle',
                    subtitle: 'Put it together',
                    color: AppColors.modePuzzleMuted,
                    comingSoon: true,
                  ),
                  // Leaves clear room above the bottom sound-toggle button.
                  const SizedBox(height: 56),
                ],
              ),
            ),
            // Figma's BottomBar sound toggle: bottom-right on every screen.
            const SoundToggleButton(),
            // Privacy policy: bottom-left, Home screen only.
            const PrivacyPolicyButton(),
          ],
        ),
      ),
    );
  }
}
