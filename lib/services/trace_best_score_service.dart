import 'package:shared_preferences/shared_preferences.dart';

/// Persists each Draw-game set's best average score across app launches —
/// the Dart equivalent of the "Tiny Tracers" prototype's `localStorage`
/// best-score keys.
class TraceBestScoreService {
  TraceBestScoreService._internal();
  static final TraceBestScoreService instance = TraceBestScoreService._internal();

  static const _keyPrefix = 'tiny_tracers_best_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// The saved best score (0-100) for [setId] ("shapes"/"numbers"), or 0
  /// if this set hasn't been completed yet.
  Future<int> getBest(String setId) async {
    try {
      final prefs = await _ensurePrefs();
      return prefs.getInt('$_keyPrefix$setId') ?? 0;
    } catch (_) {
      // A missing/unavailable preferences store should never block play.
      return 0;
    }
  }

  /// Saves [score] as the new best for [setId] only if it beats the one
  /// already stored. Returns true when it was a new best.
  Future<bool> saveIfBest(String setId, int score) async {
    try {
      final prefs = await _ensurePrefs();
      final key = '$_keyPrefix$setId';
      final prev = prefs.getInt(key) ?? 0;
      if (score > prev) {
        await prefs.setInt(key, score);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
