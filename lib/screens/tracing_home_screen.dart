import 'package:flutter/material.dart';

import '../models/trace_shape.dart';
import '../services/trace_best_score_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/sound_toggle_button.dart';
import 'tracing_game_screen.dart';

/// The Draw game's own picker: Shapes, Numbers, and a disabled "Letters"
/// tile for a set that doesn't exist yet. Ported from the "Tiny Tracers"
/// prototype's home screen, re-themed to match the rest of Nimble Kids.
class TracingHomeScreen extends StatefulWidget {
  const TracingHomeScreen({super.key});

  @override
  State<TracingHomeScreen> createState() => _TracingHomeScreenState();
}

class _TracingHomeScreenState extends State<TracingHomeScreen> {
  final Map<String, int> _bests = {};

  @override
  void initState() {
    super.initState();
    _loadBests();
  }

  Future<void> _loadBests() async {
    for (final id in kTraceSets.keys) {
      final best = await TraceBestScoreService.instance.getBest(id);
      if (!mounted) return;
      if (best > 0) setState(() => _bests[id] = best);
    }
  }

  void _openSet(TraceSet set) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TracingGameScreen(set: set)),
    ).then((_) {
      // Picking up a freshly-saved best score after a round finishes.
      _loadBests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shapes = kTraceSets['shapes']!;
    final numbers = kTraceSets['numbers']!;
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
                  AppHeader(title: 'Pick a game to draw', onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 24),
                  _TraceTile(
                    icon: Icons.category_rounded,
                    title: shapes.name,
                    subtitle: shapes.subtitle,
                    color: AppColors.traceStart,
                    best: _bests['shapes'],
                    onTap: () => _openSet(shapes),
                  ),
                  const SizedBox(height: 16),
                  _TraceTile(
                    icon: Icons.format_list_numbered_rounded,
                    title: numbers.name,
                    subtitle: numbers.subtitle,
                    color: AppColors.modeDrawPurple,
                    best: _bests['numbers'],
                    onTap: () => _openSet(numbers),
                  ),
                  const SizedBox(height: 16),
                  _TraceTile(
                    icon: Icons.abc_rounded,
                    title: 'Letters',
                    subtitle: 'A, B, C and friends',
                    color: AppColors.correctGreen,
                    best: null,
                    comingSoon: true,
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SoundToggleButton(),
          ],
        ),
      ),
    );
  }
}

class _TraceTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int? best;
  final bool comingSoon;
  final VoidCallback? onTap;

  const _TraceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.best,
    this.comingSoon = false,
    required this.onTap,
  });

  @override
  State<_TraceTile> createState() => _TraceTileState();
}

class _TraceTileState extends State<_TraceTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return Opacity(
      opacity: disabled ? 0.75 : 1,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _scale = 0.97),
        onTapUp: disabled ? null : (_) => setState(() => _scale = 1.0),
        onTapCancel: disabled ? null : () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppTheme.categoryCardRadius),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 7)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: AppTheme.boldHeadingFontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontFamily: AppTheme.bodyFontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (widget.best != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.traceHit,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Best ${widget.best}%',
                            style: const TextStyle(
                              fontFamily: AppTheme.boldHeadingFontFamily,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.traceHit,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Coming soon',
                      style: TextStyle(
                        fontFamily: AppTheme.boldHeadingFontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.5), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
