import 'package:flutter/material.dart';

/// Wraps [child] in a slow, continuous, subtle "breathing" scale animation
/// so tappable elements feel a little more alive and inviting for kids —
/// without being distracting. Set [enabled] to false to settle back to
/// scale 1.0 (e.g. once a card has already been tapped/answered).
class PulsingScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double maxScale;
  final Duration duration;

  const PulsingScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.maxScale = 1.035,
    this.duration = const Duration(milliseconds: 1300),
  });

  @override
  State<PulsingScale> createState() => _PulsingScaleState();
}

class _PulsingScaleState extends State<PulsingScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: widget.maxScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulsingScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(0, duration: const Duration(milliseconds: 150));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
    );
  }
}
