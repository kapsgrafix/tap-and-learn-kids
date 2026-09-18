import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../services/image_precache_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/mode_card.dart';
import '../widgets/privacy_policy_button.dart';
import '../widgets/sound_toggle_button.dart';
import 'category_select_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The "Nimble Kids" wordmark is baked into this logo
                  // artwork itself, so there's no separate title text here.
                  const MascotWidget(size: 260),
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
                  const SizedBox(height: 56),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ModeCard(
                        title: 'Learn',
                        subtitle: 'the word',
                        iconAsset: 'assets/images/home/learn_icon.webp',
                        color: AppColors.modeLearnGreen,
                        onTap: () => _openCategorySelect(GameMode.learn),
                      ),
                      const SizedBox(width: 16),
                      ModeCard(
                        title: 'Guess',
                        subtitle: 'the word',
                        iconAsset: 'assets/images/home/guess_icon.webp',
                        color: AppColors.modeGuessCoral,
                        onTap: () => _openCategorySelect(GameMode.guess),
                      ),
                    ],
                  ),
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
