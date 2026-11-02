import 'dart:math' as math;

import 'trace_shape.dart';

/// The result of scoring one finished trace attempt.
class TraceScoreResult {
  /// 0-100, rounded — what's shown to the child and saved as a best score.
  final int score;

  /// 0-1 — how much of the outline's circumference was actually visited,
  /// regardless of how neatly. Used to tell "went all the way around but
  /// wobbled" apart from "only traced part of it".
  final double coverage;

  const TraceScoreResult({required this.score, required this.coverage});
}

/// Scores how closely a child's finger strokes followed [item]'s outline.
///
/// Ported from the prototype's `evaluate()`: every traced point is matched
/// to its nearest point on the item's dense resampled outline (brute
/// force — outlines are only a few hundred points, so this is cheap even
/// per pointer-move event) and turned into a 0-1 "precision" value that
/// falls off with distance; a coarse set of [kTraceBins] slices along the
/// outline separately tracks whether the child went all the way around.
/// The final score is coverage * precision, so tracing one tiny bit
/// perfectly never scores well, and going all the way around sloppily
/// scores only a little better than not trying.
TraceScoreResult evaluateTrace(TraceItem item, List<List<TracePoint>> strokes) {
  final dense = item.dense;
  final n = dense.length;
  final bins = List<bool>.filled(kTraceBins, false);
  double sum = 0;
  var count = 0;

  for (final stroke in strokes) {
    for (final p in stroke) {
      var bestDist2 = double.infinity;
      var bestIndex = 0;
      for (var k = 0; k < n; k++) {
        final dx = p.u - dense[k].u;
        final dy = p.v - dense[k].v;
        final d2 = dx * dx + dy * dy;
        if (d2 < bestDist2) {
          bestDist2 = d2;
          bestIndex = k;
        }
      }
      final dev = math.sqrt(bestDist2);
      sum += math.max(0.0, 1 - dev / (kTraceTolerance * 2.5));
      count++;
      if (dev <= kTraceTolerance && n > 0) {
        final bin = ((bestIndex / n) * kTraceBins).floor().clamp(0, kTraceBins - 1).toInt();
        bins[bin] = true;
      }
    }
  }

  final covered = bins.where((b) => b).length;
  final coverage = kTraceBins > 0 ? covered / kTraceBins : 0.0;
  final precision = count > 0 ? sum / count : 0.0;
  final score = (100 * coverage * precision).round().clamp(0, 100).toInt();
  return TraceScoreResult(score: score, coverage: coverage);
}

/// Star rating shown on the result screen: 1-3.
int starsForScore(int score) => score >= 80 ? 3 : (score >= 55 ? 2 : 1);
