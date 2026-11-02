import 'dart:math' as math;

/// Tracing-game geometry, ported line-for-line from the "Tiny Tracers"
/// prototype (a standalone HTML/canvas game) so the on-screen outlines,
/// dotted guides and scoring all behave exactly as they did there.
///
/// Every point below is in "radius units" — an offset from the board's
/// center where 1.0 == the board's drawing radius (see TracingBoard,
/// which multiplies by the actual on-screen radius). The prototype's
/// canvas y-axis grows downward, and that convention is kept here too, so
/// every angle/arc constant below can be transcribed byte-for-byte from
/// the original without re-deriving the art.

/// A single point on a trace outline, in radius units.
class TracePoint {
  final double u;
  final double v;
  const TracePoint(this.u, this.v);

  TracePoint lerpTo(TracePoint other, double t) =>
      TracePoint(u + (other.u - u) * t, v + (other.v - v) * t);
}

double _hypot(double a, double b) => math.sqrt(a * a + b * b);

double _dist(TracePoint a, TracePoint b) => _hypot(b.u - a.u, b.v - a.v);

// ---------- scoring/geometry constants (shared with the scoring engine) ----------

/// Distance between the resampled points used to measure accuracy.
const double kTraceSpacing = 0.013;

/// Slices used to check that the whole outline was covered.
const int kTraceBins = 72;

/// Allowed wobble, as a fraction of the board radius.
const double kTraceTolerance = 0.22;

/// How close a finger must pass to light up a dot.
const double kTraceHitRadius = 0.18;

/// Spacing between dots along the guide.
const double kTraceDotGap = 0.115;

// ---------- path builder (mirrors the prototype's PB()) ----------

/// Builds an outline as a flat list of [TracePoint]s from move/line/arc
/// steps — the Dart equivalent of the prototype's tiny `PB()` helper.
class PathBuilder {
  final List<TracePoint> _pts = [];

  /// Starts (or continues) the outline at (x, y).
  PathBuilder m(double x, double y) {
    _pts.add(TracePoint(x, y));
    return this;
  }

  /// A straight line to (x, y).
  PathBuilder l(double x, double y) {
    _pts.add(TracePoint(x, y));
    return this;
  }

  /// An elliptical arc. Angles in degrees; increasing angle sweeps
  /// clockwise on screen, matching the canvas/y-down convention above.
  PathBuilder a(double cx, double cy, double rx, double ry, double a0, double a1) {
    final n = math.max(2, ((a1 - a0).abs() / 4).ceil());
    for (var i = 0; i <= n; i++) {
      final ang = (a0 + (a1 - a0) * (i / n)) * math.pi / 180.0;
      _pts.add(TracePoint(cx + rx * math.cos(ang), cy + ry * math.sin(ang)));
    }
    return this;
  }

  List<TracePoint> get() => List.unmodifiable(_pts);
}

PathBuilder pb() => PathBuilder();

// ---------- shape generators ----------

List<TracePoint> _circleOutline() {
  final pts = <TracePoint>[];
  for (var i = 0; i < 120; i++) {
    final a = -math.pi / 2 + (i / 120) * (2 * math.pi);
    pts.add(TracePoint(math.cos(a), math.sin(a)));
  }
  return pts;
}

List<TracePoint> _poly(List<List<double>> coords) =>
    coords.map((p) => TracePoint(p[0], p[1])).toList();

List<TracePoint> _heartOutline() {
  final pts = <TracePoint>[];
  for (var i = 0; i < 160; i++) {
    final t = (i / 160) * (2 * math.pi);
    final x = 16 * math.pow(math.sin(t), 3);
    final y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t);
    pts.add(TracePoint(x / 17, -(y + 2.5) / 17));
  }
  return pts;
}

List<TracePoint> _starOutline() {
  final pts = <TracePoint>[];
  for (var i = 0; i < 10; i++) {
    final a = -math.pi / 2 + (i * math.pi) / 5;
    final r = i % 2 == 0 ? 1.05 : 0.5;
    pts.add(TracePoint(math.cos(a) * r, math.sin(a) * r));
  }
  return pts;
}

// ---------- resampling ----------

class _Resampled {
  final List<TracePoint> pts;
  final double total;
  _Resampled(this.pts, this.total);
}

/// Walks an outline at even arc-length spacing, so later scoring never
/// cares how densely the original control points were placed.
_Resampled _resample(List<TracePoint> v, double spacing, bool closed) {
  final n0 = v.length;
  final edges = closed ? n0 : n0 - 1;
  final cum = <double>[0];
  for (var i = 0; i < edges; i++) {
    cum.add(cum[i] + _dist(v[i], v[(i + 1) % n0]));
  }
  final total = cum[edges];
  final n = math.max(8, (total / spacing).round());
  final out = <TracePoint>[];
  var j = 0;
  for (var k = 0; k < n; k++) {
    final d = closed ? (k / n) * total : (k / (n - 1)) * total;
    while (j < edges - 1 && cum[j + 1] < d) {
      j++;
    }
    final seg = cum[j + 1] - cum[j];
    final t = seg > 0 ? ((d - cum[j]) / seg).clamp(0.0, 1.0).toDouble() : 0.0;
    out.add(v[j].lerpTo(v[(j + 1) % n0], t));
  }
  return _Resampled(out, total);
}

// ---------- items (one shape or digit) ----------

/// One drawable, pen-up-separated segment of an item's outline (e.g. the
/// crossbar of a "4" is its own segment from the circle/arc body).
class TraceSegmentDef {
  final List<TracePoint> outline;
  final bool closed;

  /// True for an outline made of straight edges — dots then also sit
  /// exactly on the corners, rather than being spaced evenly along the
  /// resampled curve.
  final bool straight;

  const TraceSegmentDef({required this.outline, this.closed = false, this.straight = false});
}

class TracePolyline {
  final List<TracePoint> points;
  final bool closed;
  const TracePolyline({required this.points, required this.closed});
}

/// A single traceable shape or digit, pre-built once at app start: the
/// dense resampled outline (for scoring + the demo trail), the dotted
/// guide the child lights up, and the polylines actually drawn on the
/// board.
class TraceItem {
  final String key;
  final String label;

  /// Every resampled point across every segment, in drawing order.
  final List<TracePoint> dense;

  /// Which segment (polyline index) each `dense` point belongs to — keeps
  /// the "show me" demo trail from jumping across a pen-up gap.
  final List<int> segmentIndex;

  /// The dotted guide points the child traces over to light them up.
  final List<TracePoint> dots;

  /// The segments actually drawn on the board: the lane + the start
  /// marker both read from the first of these.
  final List<TracePolyline> polylines;

  const TraceItem({
    required this.key,
    required this.label,
    required this.dense,
    required this.segmentIndex,
    required this.dots,
    required this.polylines,
  });
}

TraceItem _makeItem(String key, String label, List<TraceSegmentDef> defs) {
  final dense = <TracePoint>[];
  final segmentIndex = <int>[];
  final dots = <TracePoint>[];
  final polylines = <TracePolyline>[];

  for (var pi = 0; pi < defs.length; pi++) {
    final d = defs[pi];
    final rs = _resample(d.outline, kTraceSpacing, d.closed);
    final pts = rs.pts;
    final n = pts.length;
    final v = d.outline;
    final nv = v.length;

    polylines.add(TracePolyline(points: pts, closed: d.closed));
    for (final p in pts) {
      dense.add(p);
      segmentIndex.add(pi);
    }

    if (d.straight) {
      final edges = d.closed ? nv : nv - 1;
      for (var i = 0; i < edges; i++) {
        final a = v[i], b = v[(i + 1) % nv];
        final segN = math.max(1, (_hypot(b.u - a.u, b.v - a.v) / kTraceDotGap).round());
        for (var j = 0; j < segN; j++) {
          dots.add(a.lerpTo(b, j / segN));
        }
      }
      if (!d.closed) dots.add(v[nv - 1]);
    } else {
      final m = math.max(1, (rs.total / kTraceDotGap).round());
      if (d.closed) {
        for (var i = 0; i < m; i++) {
          dots.add(pts[((i * n) / m).round() % n]);
        }
      } else {
        for (var i = 0; i <= m; i++) {
          dots.add(pts[((i * (n - 1)) / m).round()]);
        }
      }
    }
  }

  return TraceItem(
    key: key,
    label: label,
    dense: dense,
    segmentIndex: segmentIndex,
    dots: dots,
    polylines: polylines,
  );
}

// ---------- data: shapes ----------

final List<TraceItem> kShapeItems = [
  _makeItem('circle', 'Circle', [
    TraceSegmentDef(outline: _circleOutline(), closed: true),
  ]),
  _makeItem('square', 'Square', [
    TraceSegmentDef(
      outline: _poly([
        [-0.85, -0.85],
        [0.85, -0.85],
        [0.85, 0.85],
        [-0.85, 0.85],
      ]),
      closed: true,
      straight: true,
    ),
  ]),
  _makeItem('triangle', 'Triangle', [
    TraceSegmentDef(
      outline: _poly([
        [0, -1],
        [0.98, 0.78],
        [-0.98, 0.78],
      ]),
      closed: true,
      straight: true,
    ),
  ]),
  _makeItem('heart', 'Heart', [
    TraceSegmentDef(outline: _heartOutline(), closed: true),
  ]),
  _makeItem('star', 'Star', [
    TraceSegmentDef(outline: _starOutline(), closed: true, straight: true),
  ]),
];

// ---------- data: numbers 1-10 ----------

final List<TraceItem> kNumberItems = [
  _makeItem('1', '1', [
    TraceSegmentDef(
      outline: pb().m(-0.3, -0.55).l(0.15, -0.9).l(0.15, 0.9).get(),
      straight: true,
    ),
  ]),
  _makeItem('2', '2', [
    TraceSegmentDef(
      outline: pb().a(0, -0.45, 0.55, 0.45, 180, 400).l(-0.6, 0.9).l(0.65, 0.9).get(),
    ),
  ]),
  _makeItem('3', '3', [
    TraceSegmentDef(
      outline: pb().a(0, -0.45, 0.5, 0.45, 200, 450).a(0, 0.45, 0.55, 0.45, 270, 520).get(),
    ),
  ]),
  _makeItem('4', '4', [
    TraceSegmentDef(
      outline: pb().m(0.3, -0.9).l(-0.65, 0.35).l(0.7, 0.35).get(),
      straight: true,
    ),
    TraceSegmentDef(
      outline: pb().m(0.3, -0.9).l(0.3, 0.9).get(),
      straight: true,
    ),
  ]),
  _makeItem('5', '5', [
    TraceSegmentDef(
      outline: pb()
          .m(0.55, -0.9)
          .l(-0.45, -0.9)
          .l(-0.55, -0.1)
          .a(0, 0.35, 0.6, 0.55, 235, 520)
          .get(),
    ),
  ]),
  _makeItem('6', '6', [
    TraceSegmentDef(
      outline: pb()
          .a(0.1, 0, 0.7, 0.9, 300, 180)
          .l(-0.6, 0.4)
          .a(0, 0.4, 0.6, 0.5, 180, -180)
          .get(),
    ),
  ]),
  _makeItem('7', '7', [
    TraceSegmentDef(
      outline: pb().m(-0.6, -0.9).l(0.6, -0.9).l(-0.2, 0.9).get(),
      straight: true,
    ),
  ]),
  _makeItem('8', '8', [
    TraceSegmentDef(
      outline: pb()
          .a(0, -0.45, 0.45, 0.45, 300, 90)
          .a(0, 0.45, 0.55, 0.45, 270, 630)
          .a(0, -0.45, 0.45, 0.45, 90, -60)
          .get(),
    ),
  ]),
  _makeItem('9', '9', [
    TraceSegmentDef(
      outline:
          pb().a(0, -0.4, 0.55, 0.5, 0, -360).l(0.5, 0.3).a(0, 0.3, 0.5, 0.6, 0, 120).get(),
    ),
  ]),
  _makeItem('10', '10', [
    TraceSegmentDef(
      outline: pb().m(-0.9, -0.55).l(-0.6, -0.9).l(-0.6, 0.9).get(),
      straight: true,
    ),
    TraceSegmentDef(
      outline: pb().a(0.45, 0, 0.42, 0.9, 270, 630).get(),
      closed: true,
    ),
  ]),
];

// ---------- sets ----------

enum TracePipStyle { icon, dot }

/// Groups items into one of the Draw game's two pickable sets (a third,
/// Letters, exists in the original prototype as a disabled "coming soon"
/// tile and isn't ported — there's nothing behind it yet).
class TraceSet {
  final String id;
  final String name;
  final String subtitle;
  final List<TraceItem> items;
  final TracePipStyle pipStyle;
  final String Function(TraceItem item) tagLabel;

  const TraceSet({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.items,
    required this.pipStyle,
    required this.tagLabel,
  });
}

final Map<String, TraceSet> kTraceSets = {
  'shapes': TraceSet(
    id: 'shapes',
    name: 'Shapes',
    subtitle: 'Circle, heart, star and more',
    items: kShapeItems,
    pipStyle: TracePipStyle.icon,
    tagLabel: (item) => item.label,
  ),
  'numbers': TraceSet(
    id: 'numbers',
    name: 'Numbers',
    subtitle: 'Count from 1 to 10',
    items: kNumberItems,
    pipStyle: TracePipStyle.dot,
    tagLabel: (item) => 'Number ${item.label}',
  ),
};
