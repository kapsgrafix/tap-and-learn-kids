import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatefulWidget {
  final GameCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final hasIcon = widget.category.iconAsset.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.category.color,
            borderRadius: BorderRadius.circular(AppTheme.categoryCardRadius),
            boxShadow: [
              BoxShadow(
                color: widget.category.color.withOpacity(0.45),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: hasIcon
                    ? Image.asset(widget.category.iconAsset, fit: BoxFit.contain)
                    : const Icon(Icons.palette_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 10),
              Text(
                widget.category.name,
                style: const TextStyle(
                  fontFamily: AppTheme.headingFontFamily,
                  color: AppColors.textInverse,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
