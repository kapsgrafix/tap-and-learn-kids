import 'package:audioplayers/audioplayers.dart';

/// Wraps [audioplayers] with two independent channels — one for word
/// narration/phrases, one for short feedback sound effects — so a
/// "correct!" chime never gets cut off by the next word starting, and
/// vice versa.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _muted = false;
  bool get muted => _muted;

  void setMuted(bool value) {
    _muted = value;
  }

  Future<void> playWord(String assetPath) async {
    if (_muted) return;
    try {
      await _voicePlayer.stop();
      // audioplayers' AssetSource paths are relative to the `assets/`
      // folder declared in pubspec.yaml.
      await _voicePlayer.play(AssetSource(_stripAssetsPrefix(assetPath)));
    } catch (_) {
      // Swallow playback errors so a missing/late-loading asset never
      // crashes a young child's game session.
    }
  }

  Future<void> playSfx(String fileName) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/sfx/$fileName'));
    } catch (_) {}
  }

  Future<void> stopAll() async {
    await _voicePlayer.stop();
    await _sfxPlayer.stop();
  }

  String _stripAssetsPrefix(String path) {
    return path.startsWith('assets/') ? path.substring('assets/'.length) : path;
  }

  void dispose() {
    _voicePlayer.dispose();
    _sfxPlayer.dispose();
  }
}
