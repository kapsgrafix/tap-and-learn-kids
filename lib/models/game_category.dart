import 'package:flutter/material.dart';
import 'game_item.dart';

/// One of the topics on the category-select screen (Fruits, Animals, ...).
class GameCategory {
  final String id;
  final String name;
  final String emojiIcon;
  final Color color;
  final List<GameItem> items;

  const GameCategory({
    required this.id,
    required this.name,
    required this.emojiIcon,
    required this.color,
    required this.items,
  });
}
