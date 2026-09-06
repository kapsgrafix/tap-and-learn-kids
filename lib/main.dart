import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait - the game grid and word prompt are designed for it.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const TapAndLearnApp()));
}

class TapAndLearnApp extends StatelessWidget {
  const TapAndLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A soft, low-volume music bed for as long as the app is open, so it's
    // already playing under the very first screen the child sees.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.startBackgroundMusic();
    });
    return MaterialApp(
      title: 'Nimble Kids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
