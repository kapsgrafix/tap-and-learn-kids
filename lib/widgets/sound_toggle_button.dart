import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

/// The global mute/unmute toggle that Figma places in a "BottomBar" in
/// the bottom-right corner of every single screen. Drop this inside a
/// [Stack] (it positions itself) alongside each screen's main content.
class SoundToggleButton extends StatefulWidget {
  const SoundToggleButton({super.key});

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton> {
  late bool _muted = AudioService.instance.muted;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 20,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _muted = !_muted;
            AudioService.instance.setMuted(_muted);
          });
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: 32,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
