import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/trace_shape.dart';
import '../theme/app_theme.dart';

/// The dotted-outline canvas a child traces with their finger — the Dart
/// port of the "Tiny Tracers" prototype's `<canvas>` board. Pure drawing
/// and gesture-capture only: the result/final overlays, buttons and the
/// draw/result/final phase machine all live in the screen that hosts this.
class TracingBoard extends StatefulWidget {
  final TraceItem item;

  /// Whether finger input is accepted right now (the screen's "draw"
  /// phase) — kept false while a result overlay is up so a stray tap on
  /// the dimmed board behind it can't start a stroke.
  final bool enabled;

  /// Called every time a stroke changes (point added, cleared, or a new
  /// item loaded) so the host screen can enable "Done" and detect the
  /// auto-finish threshold without polling.
  final void Function(double hitFraction, int totalPoints) onStrokeChanged;

  /// Called when the active finger lifts off the board.
  final VoidCallback? onPointerUp;

  const TracingBoard({
    super.key,
    required this.item,
    required this.enabled,
    required this.onStrokeChanged,
    this.onPointerUp,
  });

  @override
  State<TracingBoard> createState() => TracingBoardState();
}

class TracingBoardState extends State<TracingBoard> with SingleTickerProviderStateMixin {
  final List<List<TracePoint>> _strokes = [];
  List<bool> _hits = [];
  int? _activePointer;
  List<TracePoint>? _current;
  Size _boardSize = Size.zero;

  Ticker? _ticker;
  Duration _demoStart = Duration.zero;
  bool _demoActive = false;
  double? _demoT;
  static const double _demoDurationMs = 2600;

  @override
  void initState() {
    super.initState();
    _hits = List.filled(widget.item.dots.length, false);
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(covariant TracingBoard old) {
    super.didUpdateWidget(old);
    if (old.item.key != widget.item.key) {
      _reset();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  // ---------- public API for the hosting screen ----------

  int get totalPoints => _strokes.fold(0, (sum, s) => sum + s.length);

  double get hitFraction {
    if (_hits.isEmpty) return 0;
    return _hits.where((h) => h).length / _hits.length;
  }

  List<List<TracePoint>> get strokes => List.unmodifiable(_strokes);

  /// Clears every stroke and lit dot so this item can be tried again.
  void clear() {
    stopDemo();
    setState(_reset);
    widget.onStrokeChanged(hitFraction, totalPoints);
  }

  void _reset() {
    _strokes.clear();
    _hits = List.filled(widget.item.dots.length, false);
    _current = null;
    _activePointer = null;
  }

  /// Plays the "show me" ghost-trail animation along the outline once.
  void startDemo() {
    _demoStart = Duration.zero;
    _demoActive = true;
    _demoT = 0;
    _ticker?.start();
  }

  void stopDemo() {
    _demoActive = false;
    _demoT = null;
    _ticker?.stop();
  }

  void _onTick(Duration elapsed) {
    if (_demoStart == Duration.zero) _demoStart = elapsed;
    final t = (elapsed - _demoStart).inMilliseconds / _demoDurationMs;
    if (t >= 1.15) {
      stopDemo();
      setState(() {});
      return;
    }
    setState(() => _demoT = t);
  }

  // ---------- geometry ----------

  double _radiusFor(Size size) => math.min(size.width, size.height) * 0.34;

  TracePoint _toUnit(Offset local, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = _radiusFor(size);
    return TracePoint((local.dx - cx) / (r == 0 ? 1 : r), (local.dy - cy) / (r == 0 ? 1 : r));
  }

  void _markHits(TracePoint p) {
    final dots = widget.item.dots;
    for (var i = 0; i < dots.length; i++) {
      if (_hits[i]) continue;
      final dx = p.u - dots[i].u, dy = p.v - dots[i].v;
      if (dx * dx + dy * dy <= kTraceHitRadius * kTraceHitRadius) _hits[i] = true;
    }
  }

  void _addPoint(Offset local) {
    final p = _toUnit(local, _boardSize);
    final cur = _current!;
    final last = cur.isNotEmpty ? cur.last : null;
    if (last != null) {
      final du = p.u - last.u, dv = p.v - last.v;
      final steps = math.max(1, (math.sqrt(du * du + dv * dv) / 0.03).ceil());
      for (var s = 1; s <= steps; s++) {
        final step = TracePoint(last.u + du * (s / steps), last.v + dv * (s / steps));
        cur.add(step);
        _markHits(step);
      }
    } else {
      cur.add(p);
      _markHits(p);
    }
  }

  // ---------- pointer handling ----------

  void _onPointerDown(PointerDownEvent e) {
    if (!widget.enabled || _activePointer != null) return;
    stopDemo();
    _activePointer = e.pointer;
    _current = <TracePoint>[];
    _strokes.add(_current!);
    setState(() => _addPoint(e.localPosition));
    widget.onStrokeChanged(hitFraction, totalPoints);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _activePointer || _current == null) return;
    setState(() => _addPoint(e.localPosition));
    widget.onStrokeChanged(hitFraction, totalPoints);
  }

  void _onPointerEnd(int pointer) {
    if (pointer != _activePointer) return;
    _activePointer = null;
    _current = null;
    widget.onPointerUp?.call();
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _boardSize = constraints.biggest;
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: (e) => _onPointerEnd(e.pointer),
          onPointerCancel: (e) => _onPointerEnd(e.pointer),
          child: CustomPaint(
            size: _boardSize,
            painter: _TracingPainter(
              item: widget.item,
              strokes: _strokes,
              hits: _hits,
              showStartMarker: widget.enabled && _strokes.isEmpty,
              demoProgress: _demoT,
            ),
          ),
        );
      },
    );
  }
}

class _TracingPainter extends CustomPainter {
  final TraceItem item;
  final List<List<TracePoint>> strokes;
  final List<bool> hits;
  final bool showStartMarker;
  final double? demoProgress;

  _TracingPainter({
    required this.item,
    required this.strokes,
    required this.hits,
    required this.showStartMarker,
    required this.demoProgress,
  });

  double _clamp(double n, double lo, double hi) => math.max(lo, math.min(hi, n));

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.34;
    double x(double u) => cx + u * r;
    double y(double v) => cy + v * r;

    final strokeW = _clamp(r * 0.17, 16, 30);
    final dotR = _clamp(r * 0.045, 4, 7);

    // The lane the child should stay inside.
    final lanePaint = Paint()
      ..color = AppColors.traceTrack
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = r * kTraceTolerance * 2;
    for (final pl in item.polylines) {
      final path = Path()..moveTo(x(pl.points.first.u), y(pl.points.first.v));
      for (var i = 1; i < pl.points.length; i++) {
        path.lineTo(x(pl.points[i].u), y(pl.points[i].v));
      }
      if (pl.closed) path.close();
      canvas.drawPath(path, lanePaint);
    }

    // The child's own finger strokes.
    final inkStroke = Paint()
      ..color = AppColors.traceStroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeW;
    final inkFill = Paint()..color = AppColors.traceStroke;
    for (final s in strokes) {
      if (s.isEmpty) continue;
      if (s.length == 1) {
        canvas.drawCircle(Offset(x(s[0].u), y(s[0].v)), strokeW / 2, inkFill);
      } else {
        final path = Path()..moveTo(x(s[0].u), y(s[0].v));
        for (var k = 1; k < s.length; k++) {
          path.lineTo(x(s[k].u), y(s[k].v));
        }
        canvas.drawPath(path, inkStroke);
      }
    }

    // The dotted outline on top, so covered dots light up.
    final dots = item.dots;
    for (var i = 0; i < dots.length; i++) {
      final hit = i < hits.length && hits[i];
      final paint = Paint()..color = hit ? AppColors.traceHit : AppColors.traceDot;
      canvas.drawCircle(Offset(x(dots[i].u), y(dots[i].v)), hit ? dotR * 1.45 : dotR, paint);
      if (hit) {
        final ring = Paint()
          ..color = AppColors.bgCard
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(x(dots[i].u), y(dots[i].v)), dotR * 1.45, ring);
      }
    }

    // Start marker with an arrow showing which way to go.
    if (showStartMarker && item.polylines.isNotEmpty) {
      final first = item.polylines.first.points;
      final p0 = first.first;
      final p1 = first[math.min(4, first.length - 1)];
      var tx = p1.u - p0.u, ty = p1.v - p0.v;
      final tl = math.sqrt(tx * tx + ty * ty);
      if (tl > 0) {
        tx /= tl;
        ty /= tl;
      } else {
        tx = 1;
        ty = 0;
      }
      final sx = x(p0.u), sy = y(p0.v);
      final sr = _clamp(r * 0.1, 11, 17);
      canvas.drawCircle(Offset(sx, sy), sr, Paint()..color = AppColors.traceStart);
      canvas.drawCircle(
        Offset(sx, sy),
        sr,
        Paint()
          ..color = AppColors.bgCard
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final bx = sx + tx * (sr + 8), by = sy + ty * (sr + 8);
      final arrow = Path()
        ..moveTo(bx - ty * 9, by + tx * 9)
        ..lineTo(sx + tx * (sr + 23), sy + ty * (sr + 23))
        ..lineTo(bx + ty * 9, by - tx * 9)
        ..close();
      canvas.drawPath(arrow, Paint()..color = AppColors.traceStart);
    }

    // The "watch me" ghost trail.
    final t = demoProgress;
    if (t != null) {
      final pr = math.min(t, 1.0);
      final e = pr < 0.5 ? 2 * pr * pr : 1 - math.pow(-2 * pr + 2, 2) / 2;
      final fade = t > 1 ? 1 - (t - 1) / 0.15 : 1.0;
      final gr = _clamp(r * 0.12, 13, 20);
      final dense = item.dense, segIndex = item.segmentIndex;
      final last = dense.length - 1;
      final head = (e * last).floor().clamp(0, last).toInt();
      for (var j = 7; j >= 0; j--) {
        final idx = (e * last - j * 0.012 * last).floor();
        if (idx < 0 || idx > last || segIndex[idx] != segIndex[head]) continue;
        final q = dense[idx];
        final alpha = (math.max(0, fade) * (j == 0 ? 1.0 : 0.5 * (1 - j / 8))).clamp(0.0, 1.0).toDouble();
        final paint = Paint()..color = AppColors.traceStart.withOpacity(alpha);
        canvas.drawCircle(Offset(x(q.u), y(q.v)), gr * (1 - j * 0.07), paint);
        if (j == 0) {
          canvas.drawCircle(
            Offset(x(q.u), y(q.v)),
            gr * (1 - j * 0.07),
            Paint()
              ..color = AppColors.bgCard.withOpacity(alpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) => true;
}
