import 'dart:math';
import 'package:flutter/material.dart';

/// A small, dependency-free confetti burst for the "Well done!" screen.
/// Pieces fall from the top of the widget and fade out near the bottom.
class ConfettiBurst extends StatefulWidget {
  final int pieceCount;
  const ConfettiBurst({super.key, this.pieceCount = 60});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;
  final _rand = Random();

  static const _colors = [
    Color(0xFFFFC93C),
    Color(0xFFFF6FB5),
    Color(0xFF5D9CEC),
    Color(0xFF7ED957),
    Color(0xFFB388FF),
    Color(0xFFFF8A3D),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _pieces = List.generate(widget.pieceCount, (i) {
      return _Piece(
        x: _rand.nextDouble(),
        delay: _rand.nextDouble() * 0.6,
        speed: 0.6 + _rand.nextDouble() * 0.6,
        size: 6 + _rand.nextDouble() * 6,
        color: _colors[_rand.nextInt(_colors.length)],
        spin: (_rand.nextDouble() - 0.5) * 8,
        sway: _rand.nextDouble() * 30 + 10,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(pieces: _pieces, t: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Piece {
  final double x; // 0..1 horizontal position
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final double spin;
  final double sway;

  _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.spin,
    required this.sway,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;

  _ConfettiPainter({required this.pieces, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      double localT = (t - p.delay);
      if (localT < 0) localT += 1;
      localT = (localT * p.speed) % 1.0;

      final dy = localT * (size.height + 40) - 20;
      final dx = p.x * size.width + sin(localT * 2 * pi * 2) * p.sway;
      final opacity = localT > 0.85 ? (1 - localT) / 0.15 : 1.0;

      final paint = Paint()..color = p.color.withOpacity(opacity.clamp(0, 1));
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(localT * p.spin);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// A small one-shot confetti "pop" that radiates outward from the center of
/// whatever it wraps, then fades. Used on an individual answer card the
/// moment it's tapped correctly — a lighter-weight celebration than the
/// full-screen [ConfettiBurst] on the results screen.
class MiniConfettiBurst extends StatefulWidget {
  final bool trigger;
  const MiniConfettiBurst({super.key, required this.trigger});

  @override
  State<MiniConfettiBurst> createState() => _MiniConfettiBurstState();
}

class _MiniConfettiBurstState extends State<MiniConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_MiniParticle> _particles;
  final _rand = Random();

  static const _colors = [
    Color(0xFFFFC93C),
    Color(0xFFFF6FB5),
    Color(0xFF5D9CEC),
    Color(0xFF7ED957),
    Color(0xFFB388FF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _particles = List.generate(14, (i) {
      final angle = (i / 14) * 2 * pi + _rand.nextDouble() * 0.35;
      return _MiniParticle(
        angle: angle,
        distance: 28 + _rand.nextDouble() * 20,
        size: 5 + _rand.nextDouble() * 4,
        color: _colors[_rand.nextInt(_colors.length)],
        spin: (_rand.nextDouble() - 0.5) * 6,
      );
    });
    if (widget.trigger) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant MiniConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _MiniConfettiPainter(particles: _particles, progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _MiniParticle {
  final double angle;
  final double distance;
  final double size;
  final double spin;
  final Color color;

  _MiniParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.spin,
  });
}

class _MiniConfettiPainter extends CustomPainter {
  final List<_MiniParticle> particles;
  final double progress;

  _MiniConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = size.center(Offset.zero);
    final eased = Curves.easeOut.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    for (final p in particles) {
      final dist = p.distance * eased;
      final dx = cos(p.angle) * dist;
      final dy = sin(p.angle) * dist - progress * 10;
      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.save();
      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.rotate(p.spin * progress * pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MiniConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
