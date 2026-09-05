import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Big, rounded, bouncy button sized for small fingers.
///
/// Set [breathing] to true for a slow, continuous "come tap me" pulse —
/// used on the two main call-to-action buttons (Let's Play!, Play Again)
/// so they draw a young child's eye even before anything is tapped.
class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final String? fontFamily;
  final bool breathing;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.brandTeal,
    this.fontFamily,
    this.breathing = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  double _pressScale = 1.0;
  AnimationController? _breathController;
  Animation<double>? _breathScale;

  @override
  void initState() {
    super.initState();
    if (widget.breathing) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true);
      _breathController = controller;
      _breathScale = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _breathController?.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: AppColors.textInverse, size: 24),
            const SizedBox(width: 12),
          ],
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: widget.fontFamily ?? AppTheme.bodyFontFamily,
              color: AppColors.textInverse,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    final breathController = _breathController;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressScale = 0.94),
      onTapUp: (_) => setState(() => _pressScale = 1.0),
      onTapCancel: () => setState(() => _pressScale = 1.0),
      onTap: widget.onPressed,
      child: breathController == null
          ? AnimatedScale(
              scale: _pressScale,
              duration: const Duration(milliseconds: 100),
              child: content,
            )
          : AnimatedBuilder(
              animation: breathController,
              child: content,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathScale!.value * _pressScale,
                  child: child,
                );
              },
            ),
    );
  }
}
