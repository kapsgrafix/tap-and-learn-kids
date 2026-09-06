import 'package:audioplayers/audioplayers.dart';

/// Wraps [audioplayers] with three independent channels — word
/// narration/phrases, short feedback sound effects, and a quiet looping
/// background music bed — so a "correct!" chime never gets cut off by the
/// next word starting, and neither ever has to compete for the same player
/// as the music running underneath them.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _muted = false;
  bool get muted => _muted;

  bool _musicStarted = false;

  // Kept low on purpose: this plays continuously under word narration and
  // sound effects, so it must always read as a soft background bed rather
  // than something competing for the child's attention.
  static const double _musicVolume = 0.16;

  void setMuted(bool value) {
    _muted = value;
    if (value) {
      _musicPlayer.pause();
    } else if (_musicStarted) {
      _musicPlayer.resume();
    }
  }

  /// Starts the looping background music bed. Safe to call multiple times —
  /// only the first call actually starts playback. No-ops while muted, but
  /// remembers to start once unmuted.
  Future<void> startBackgroundMusic() async {
    if (_musicStarted) return;
    _musicStarted = true;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      if (!_muted) {
        await _musicPlayer.play(AssetSource('audio/music/bg_loop.mp3'));
      }
    } catch (_) {
      // A missing/late-loading music asset should never block the app.
    }
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
    await _musicPlayer.stop();
    _musicStarted = false;
  }

  String _stripAssetsPrefix(String path) {
    return path.startsWith('assets/') ? path.substring('assets/'.length) : path;
  }

  void dispose() {
    _voicePlayer.dispose();
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
