import 'package:flutter/material.dart';

/// How a [GameItem] should be drawn on its answer card.
enum VisualKind { emoji, shape, color }

/// Basic geometric shapes drawn with a [CustomPainter] rather than emoji,
/// so they render identically (and cleanly) on every device.
enum ShapeKind { circle, square, triangle, rectangle, star, heart, diamond, oval }

/// A single word the child can be asked to recognize (e.g. "Apple",
/// "Red", "Circle"). [audioAsset] is the narration clip played when the
/// question appears or when the child taps the replay button.
class GameItem {
  final String id;
  final String label;
  final String audioAsset;
  final VisualKind visualKind;
  final String? emoji;
  final ShapeKind? shape;
  final Color? color;

  const GameItem.emoji({
    required this.id,
    required this.label,
    required this.audioAsset,
    required this.emoji,
  })  : visualKind = VisualKind.emoji,
        shape = null,
        color = null;

  const GameItem.shape({
    required this.id,
    required this.label,
    required this.audioAsset,
    required this.shape,
    required this.color,
  })  : visualKind = VisualKind.shape,
        emoji = null;

  const GameItem.color({
    required this.id,
    required this.label,
    required this.audioAsset,
    required this.color,
  })  : visualKind = VisualKind.color,
        emoji = null,
        shape = null;
}
