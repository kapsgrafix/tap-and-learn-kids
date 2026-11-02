import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One full-width Home-screen choice — Guess, Draw, or (disabled) Puzzle.
/// Supersedes the old fixed-160x173 two-up [ModeCard] row now that Home
/// shows three choices stacked vertically instead of two side by side.
class HomeGameTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool comingSoon;
  final VoidCallback? onTap;

  const HomeGameTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.comingSoon = false,
    this.onTap,
  });

  @override
  State<HomeGameTile> createState() => _HomeGameTileState();
}

class _HomeGameTileState extends State<HomeGameTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return Opacity(
      opacity: disabled ? 0.8 : 1,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _scale = 0.97),
        onTapUp: disabled ? null : (_) => setState(() => _scale = 1.0),
        onTapCancel: disabled ? null : () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(AppTheme.categoryCardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(widget.icon, color: AppColors.textInverse, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: AppTheme.boldHeadingFontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: AppColors.textInverse,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontFamily: AppTheme.headingFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textInverse,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontFamily: AppTheme.boldHeadingFontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: widget.color,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textInverse, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
