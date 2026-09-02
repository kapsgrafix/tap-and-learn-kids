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
