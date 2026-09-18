import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Every screen has a light (cream/yellow) background, so the status bar's
  // clock/signal/battery icons need to render dark - left at the system
  // default they render white and disappear against it.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  // Lock to portrait - the game grid and word prompt are designed for it.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const TapAndLearnApp()));
}

class TapAndLearnApp extends StatefulWidget {
  const TapAndLearnApp({super.key});

  @override
  State<TapAndLearnApp> createState() => _TapAndLearnAppState();
}

class _TapAndLearnAppState extends State<TapAndLearnApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A soft, low-volume music bed for as long as the app is open, so it's
    // already playing under the very first screen the child sees.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.startBackgroundMusic();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause the music the moment the app is actually backgrounded/minimized
    // (not on merely transient states like a system dialog), and pick it
    // back up the moment the child returns to the app.
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        AudioService.instance.pauseForBackground();
        break;
      case AppLifecycleState.resumed:
        AudioService.instance.resumeFromBackground();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nimble Kids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
