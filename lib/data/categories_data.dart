import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';

const _wordsPath = 'assets/audio/words';

GameItem _emojiItem(String label, String emoji) => GameItem.emoji(
      id: label.toLowerCase(),
      label: label,
      audioAsset: '$_wordsPath/${label.toLowerCase()}.mp3',
      emoji: emoji,
    );

GameItem _colorItem(String label, Color color) => GameItem.color(
      id: 'color_${label.toLowerCase()}',
      label: label,
      audioAsset: '$_wordsPath/color_${label.toLowerCase()}.mp3',
      color: color,
    );

GameItem _shapeItem(String label, ShapeKind shape, Color color) => GameItem.shape(
      id: 'shape_${label.toLowerCase()}',
      label: label,
      audioAsset: '$_wordsPath/shape_${label.toLowerCase()}.mp3',
      shape: shape,
      color: color,
    );

/// All five phase-1 categories and their recognizable items.
final List<GameCategory> gameCategories = [
  GameCategory(
    id: 'fruits',
    name: 'Fruits',
    emojiIcon: '🍎',
    color: AppColors.wrongRed,
    items: [
      _emojiItem('Apple', '🍎'),
      _emojiItem('Banana', '🍌'),
      _emojiItem('Orange', '🍊'),
      _emojiItem('Grapes', '🍇'),
      _emojiItem('Watermelon', '🍉'),
      _emojiItem('Strawberry', '🍓'),
      _emojiItem('Mango', '🥭'),
      _emojiItem('Pineapple', '🍍'),
      _emojiItem('Pear', '🍐'),
      _emojiItem('Cherry', '🍒'),
      _emojiItem('Lemon', '🍋'),
      _emojiItem('Peach', '🍑'),
    ],
  ),
  GameCategory(
    id: 'animals',
    name: 'Animals',
    emojiIcon: '🦁',
    color: AppColors.warmOrange,
    items: [
      _emojiItem('Dog', '🐶'),
      _emojiItem('Cat', '🐱'),
      _emojiItem('Lion', '🦁'),
      _emojiItem('Elephant', '🐘'),
      _emojiItem('Monkey', '🐒'),
      _emojiItem('Rabbit', '🐰'),
      _emojiItem('Horse', '🐴'),
      _emojiItem('Cow', '🐮'),
      _emojiItem('Tiger', '🐯'),
      _emojiItem('Bear', '🐻'),
      _emojiItem('Fox', '🦊'),
      _emojiItem('Pig', '🐷'),
    ],
  ),
  GameCategory(
    id: 'colors',
    name: 'Colors',
    emojiIcon: '🎨',
    color: AppColors.bubblePink,
    items: [
      _colorItem('Red', const Color(0xFFE53935)),
      _colorItem('Blue', const Color(0xFF1E88E5)),
      _colorItem('Yellow', const Color(0xFFFDD835)),
      _colorItem('Green', const Color(0xFF43A047)),
      _colorItem('Orange', const Color(0xFFFB8C00)),
      _colorItem('Purple', const Color(0xFF8E24AA)),
      _colorItem('Pink', const Color(0xFFEC407A)),
      _colorItem('Brown', const Color(0xFF8D6E63)),
      _colorItem('Black', const Color(0xFF3B3B3B)),
      _colorItem('White', const Color(0xFFF5F5F5)),
    ],
  ),
  GameCategory(
    id: 'vehicles',
    name: 'Vehicles',
    emojiIcon: '🚗',
    color: AppColors.skyBlueDark,
    items: [
      _emojiItem('Car', '🚗'),
      _emojiItem('Bus', '🚌'),
      _emojiItem('Bicycle', '🚲'),
      _emojiItem('Airplane', '✈️'),
      _emojiItem('Train', '🚆'),
      _emojiItem('Boat', '⛵'),
      _emojiItem('Truck', '🚚'),
      _emojiItem('Helicopter', '🚁'),
      _emojiItem('Ambulance', '🚑'),
      _emojiItem('Motorcycle', '🏍️'),
    ],
  ),
  GameCategory(
    id: 'shapes',
    name: 'Shapes',
    emojiIcon: '⭐',
    color: AppColors.grassGreen,
    items: [
      _shapeItem('Circle', ShapeKind.circle, const Color(0xFF5D9CEC)),
      _shapeItem('Square', ShapeKind.square, const Color(0xFFFF8A3D)),
      _shapeItem('Triangle', ShapeKind.triangle, const Color(0xFF7ED957)),
      _shapeItem('Rectangle', ShapeKind.rectangle, const Color(0xFFB388FF)),
      _shapeItem('Star', ShapeKind.star, const Color(0xFFFFC93C)),
      _shapeItem('Heart', ShapeKind.heart, const Color(0xFFFF6FB5)),
      _shapeItem('Diamond', ShapeKind.diamond, const Color(0xFF26C6DA)),
      _shapeItem('Oval', ShapeKind.oval, const Color(0xFFE53935)),
    ],
  ),
];
