import 'package:flutter/material.dart';
import '../data/categories_data.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import 'game_screen.dart';

class CategorySelectScreen extends StatelessWidget {
  const CategorySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.inkText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Choose to Play!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.inkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: gameCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final category = gameCategories[index];
                    return CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GameScreen(category: category)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
