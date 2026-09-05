import 'package:flutter/material.dart';
import '../services/image_precache_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
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
                  const MascotWidget(size: 240),
                  const SizedBox(height: 32),
                  const Text(
                    'Smart Kids',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: "Let's Play!",
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.categoryShapes,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategorySelectScreen()),
                      );
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
