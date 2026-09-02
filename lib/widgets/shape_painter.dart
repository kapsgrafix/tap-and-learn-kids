import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_item.dart';

/// Draws one of the basic [ShapeKind]s inside its bounds. Used for the
/// Shapes category so every device renders identical, crisp shapes
/// instead of relying on emoji glyph support.
class ShapeIcon extends StatelessWidget {
  final ShapeKind shape;
  final Color color;
  final double size;

  const ShapeIcon({super.key, required this.shape, required this.color, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(shape: shape, color: color),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeKind shape;
  final Color color;

  _ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);

    switch (shape) {
      case ShapeKind.circle:
        canvas.drawCircle(rect.center, w / 2, paint);
        break;
      case ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(w * 0.12)),
          paint,
        );
        break;
      case ShapeKind.rectangle:
        final r = Rect.fromLTWH(0, h * 0.18, w, h * 0.64);
        canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(h * 0.1)), paint);
        break;
      case ShapeKind.oval:
        final r = Rect.fromLTWH(0, h * 0.15, w, h * 0.7);
        canvas.drawOval(r, paint);
        break;
      case ShapeKind.triangle:
        final path = Path()
          ..moveTo(w / 2, 0)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(_roundPath(path, 10), paint);
        break;
      case ShapeKind.diamond:
        final path = Path()
          ..moveTo(w / 2, 0)
          ..lineTo(w, h / 2)
          ..lineTo(w / 2, h)
          ..lineTo(0, h / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeKind.star:
        canvas.drawPath(_starPath(w, h), paint);
        break;
      case ShapeKind.heart:
        canvas.drawPath(_heartPath(w, h), paint);
        break;
    }
  }

  Path _roundPath(Path path, double radius) => path; // keep triangles crisp

  Path _starPath(double w, double h) {
    const points = 5;
    final path = Path();
    final cx = w / 2, cy = h / 2;
    final outerR = w / 2;
    final innerR = outerR * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (-90 + i * 180 / points) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _heartPath(double w, double h) {
    final path = Path();
    path.moveTo(w / 2, h * 0.9);
    path.cubicTo(-w * 0.1, h * 0.55, w * 0.1, -h * 0.05, w / 2, h * 0.28);
    path.cubicTo(w * 0.9, -h * 0.05, w * 1.1, h * 0.55, w / 2, h * 0.9);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}
