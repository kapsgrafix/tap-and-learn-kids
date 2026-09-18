import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/learn_item_card.dart';
import '../widgets/sound_toggle_button.dart';

/// "Learn the word": every item in the category laid out in a 3-column
/// grid. There's no right/wrong here — tapping a picture just plays its
/// word, so the child can freely explore and re-hear anything as often as
/// they like.
class LearnScreen extends StatefulWidget {
  final GameCategory category;

  const LearnScreen({super.key, required this.category});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String? _activeItemId;

  @override
  void dispose() {
    AudioService.instance.stopAll();
    super.dispose();
  }

  void _onItemTap(String itemId, String audioAsset) {
    setState(() => _activeItemId = itemId);
    AudioService.instance.playWord(audioAsset);
    // A short highlight so the tapped card visibly stays "active" while its
    // word is most likely still sounding out.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _activeItemId == itemId) {
        setState(() => _activeItemId = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep the grid to a single comfortable screenful — a big category
    // could otherwise scroll on for pages, which is hard for a young child
    // to navigate.
    final items = widget.category.items.take(12).toList();

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
                    title: widget.category.name,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      // The tapped card briefly scales up (see LearnItemCard);
                      // without this, GridView's default hard-edge clip crops
                      // that bounce right at the grid's own bounds, which is
                      // most visible on the corner/edge cards.
                      clipBehavior: Clip.none,
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return LearnItemCard(
                          item: item,
                          categoryColor: widget.category.color,
                          isActive: _activeItemId == item.id,
                          onTap: () => _onItemTap(item.id, item.audioAsset),
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
