import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
import 'category_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MascotWidget(size: 240),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap & Learn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppColors.inkText,
                    ),
                  ),
                  const Text(
                    'Kids',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warmOrange,
                    ),
                  ),
                  const SizedBox(height: 36),
                  PrimaryButton(
                    label: "Let's Play!",
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.grassGreen,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategorySelectScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                iconSize: 30,
                icon: Icon(
                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: AppColors.inkText,
                ),
                onPressed: () {
                  setState(() {
                    _muted = !_muted;
                    AudioService.instance.setMuted(_muted);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
