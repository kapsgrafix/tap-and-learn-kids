import 'package:flutter/material.dart';
import '../data/categories_data.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/category_card.dart';
import '../widgets/sound_toggle_button.dart';
import 'game_screen.dart';
import 'learn_screen.dart';

/// Shared by both Home-screen activities — the mode decides the header
/// title and what a category tap opens next.
class CategorySelectScreen extends StatelessWidget {
  final GameMode mode;

  const CategorySelectScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeader(
                    title: mode == GameMode.learn ? 'Choose to Learn!' : 'Choose to Play!',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      itemCount: gameCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final category = gameCategories[index];
                        return CategoryCard(
                          category: category,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => mode == GameMode.learn
                                    ? LearnScreen(category: category)
                                    : GameScreen(category: category),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Figma's BottomBar sound toggle: bottom-right on every screen.
            const SoundToggleButton(),
          ],
        ),
      ),
    );
  }
}
