import '../models/game_category.dart';
import '../models/game_item.dart';
import '../theme/app_theme.dart';

const _wordsPath = 'assets/audio/words';

GameItem _item(String id, String label, String imageAsset, {String? audioId}) {
  return GameItem(
    id: id,
    label: label,
    audioAsset: '$_wordsPath/${audioId ?? id}.mp3',
    imageAsset: imageAsset,
  );
}

/// All five phase-1 categories and their recognizable items, matching the
/// exact item sets and artwork exported from the "Smart Kids" Figma file.
final List<GameCategory> gameCategories = [
  GameCategory(
    id: 'fruits',
    name: 'Fruits',
    iconAsset: 'assets/images/fruits/pineapple.webp',
    color: AppColors.categoryFruits,
    items: [
      _item('apple', 'Apple', 'assets/images/fruits/apple.webp'),
      _item('banana', 'Banana', 'assets/images/fruits/banana.webp'),
      _item('cherry', 'Cherry', 'assets/images/fruits/cherry.webp'),
      _item('grapes', 'Grapes', 'assets/images/fruits/grapes.webp'),
      _item('kiwi', 'Kiwi', 'assets/images/fruits/kiwi.webp'),
      _item('lemon', 'Lemon', 'assets/images/fruits/lemon.webp'),
      _item('mango', 'Mango', 'assets/images/fruits/mango.webp'),
      _item('orange', 'Orange', 'assets/images/fruits/orange.webp'),
      _item('papaya', 'Papaya', 'assets/images/fruits/papaya.webp'),
      _item('peach', 'Peach', 'assets/images/fruits/peach.webp'),
      _item('pear', 'Pear', 'assets/images/fruits/pear.webp'),
      _item('pineapple', 'Pineapple', 'assets/images/fruits/pineapple.webp'),
      _item('watermelon', 'Watermelon', 'assets/images/fruits/watermelon.webp'),
    ],
  ),
  GameCategory(
    id: 'animals',
    name: 'Animals',
    iconAsset: 'assets/images/animals/rabbit.webp',
    color: AppColors.categoryAnimals,
    items: [
      _item('bear', 'Bear', 'assets/images/animals/bear.webp'),
      _item('cat', 'Cat', 'assets/images/animals/cat.webp'),
      _item('cow', 'Cow', 'assets/images/animals/cow.webp'),
      _item('dog', 'Dog', 'assets/images/animals/dog.webp'),
      _item('elephant', 'Elephant', 'assets/images/animals/elephant.webp'),
      _item('fox', 'Fox', 'assets/images/animals/fox.webp'),
      _item('horse', 'Horse', 'assets/images/animals/horse.webp'),
      _item('lion', 'Lion', 'assets/images/animals/lion.webp'),
      _item('monkey', 'Monkey', 'assets/images/animals/monkey.webp'),
      _item('pig', 'Pig', 'assets/images/animals/pig.webp'),
      _item('rabbit', 'Rabbit', 'assets/images/animals/rabbit.webp'),
      _item('tiger', 'Tiger', 'assets/images/animals/tiger.webp'),
    ],
  ),
  GameCategory(
    id: 'colors',
    name: 'Colors',
    // No dedicated palette icon was exported from Figma yet — CategoryCard
    // falls back to a Material icon whenever iconAsset is empty.
    iconAsset: '',
    color: AppColors.categoryColors,
    items: [
      _item('color_black', 'Black', 'assets/images/colors/black.webp'),
      _item('color_blue', 'Blue', 'assets/images/colors/blue.webp'),
      _item('color_brown', 'Brown', 'assets/images/colors/brown.webp'),
      _item('color_green', 'Green', 'assets/images/colors/green.webp'),
      _item('color_orange', 'Orange', 'assets/images/colors/orange.webp'),
      _item('color_pink', 'Pink', 'assets/images/colors/pink.webp'),
      _item('color_purple', 'Purple', 'assets/images/colors/purple.webp'),
      _item('color_red', 'Red', 'assets/images/colors/red.webp'),
      _item('color_white', 'White', 'assets/images/colors/white.webp'),
      _item('color_yellow', 'Yellow', 'assets/images/colors/yellow.webp'),
    ],
  ),
  GameCategory(
    id: 'vehicles',
    name: 'Vehicles',
    iconAsset: 'assets/images/vehicles/car.webp',
    color: AppColors.categoryVehicles,
    items: [
      _item('airplane', 'Airplane', 'assets/images/vehicles/airplane.webp'),
      _item('ambulance', 'Ambulance', 'assets/images/vehicles/ambulance.webp'),
      _item('bicycle', 'Bicycle', 'assets/images/vehicles/bicycle.webp'),
      _item('boat', 'Boat', 'assets/images/vehicles/boat.webp'),
      _item('bus', 'Bus', 'assets/images/vehicles/bus.webp'),
      _item('car', 'Car', 'assets/images/vehicles/car.webp'),
      _item('helicopter', 'Helicopter', 'assets/images/vehicles/helicopter.webp'),
      _item('motorcycle', 'Motorcycle', 'assets/images/vehicles/motorcycle.webp'),
      _item('train', 'Train', 'assets/images/vehicles/train.webp'),
      _item('truck', 'Truck', 'assets/images/vehicles/truck.webp'),
    ],
  ),
  GameCategory(
    id: 'shapes',
    name: 'Shapes',
    iconAsset: 'assets/images/shapes/star.webp',
    color: AppColors.categoryShapes,
    items: [
      _item('shape_circle', 'Circle', 'assets/images/shapes/circle.webp'),
      _item('shape_diamond', 'Diamond', 'assets/images/shapes/diamond.webp'),
      _item('shape_heart', 'Heart', 'assets/images/shapes/heart.webp'),
      _item('shape_oval', 'Oval', 'assets/images/shapes/oval.webp'),
      _item('shape_rectangle', 'Rectangle', 'assets/images/shapes/rectangle.webp'),
      _item('shape_square', 'Square', 'assets/images/shapes/square.webp'),
      _item('shape_star', 'Star', 'assets/images/shapes/star.webp'),
      _item('shape_triangle', 'Triangle', 'assets/images/shapes/triangle.webp'),
    ],
  ),
];
