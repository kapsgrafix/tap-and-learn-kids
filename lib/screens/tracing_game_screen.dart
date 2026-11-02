import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/trace_scoring.dart';
import '../models/trace_shape.dart';
import '../services/audio_service.dart';
import '../services/trace_best_score_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_dots.dart';
import '../widgets/sound_toggle_button.dart';
import '../widgets/tracing_board.dart';

enum _Phase { draw, result, recap }

/// The Draw game itself: one item (a shape or a digit) at a time, with a
/// short celebration between each and a recap once the whole set is done.
/// Ported from the "Tiny Tracers" prototype's draw/result/final state
/// machine, re-themed to match the rest of Nimble Kids (the header, sound
/// toggle, progress dots, buttons and sfx are all the app's existing
/// building blocks rather than new bespoke ones).
class TracingGameScreen extends StatefulWidget {
  final TraceSet set;
  const TracingGameScreen({super.key, required this.set});

  @override
  State<TracingGameScreen> createState() => _TracingGameScreenState();
}

class _TracingGameScreenState extends State<TracingGameScreen> {
  final _boardKey = GlobalKey<TracingBoardState>();

  late List<int?> _scores;
  int _round = 0;
  _Phase _phase = _Phase.draw;
  bool _doneEnabled = false;
  Timer? _autoTimer;
  Timer? _advanceTimer;

  int _lastScore = 0;
  int _lastStars = 1;
  String _lastMessage = '';
  String _lastSubline = '';

  int _finalAvg = 0;
  int _finalStars = 1;
  String _finalMessage = '';
  String _finalBestLine = '';

  TraceItem get _item => widget.set.items[_round];

  bool get _reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

  @override
  void initState() {
    super.initState();
    _scores = List<int?>.filled(widget.set.items.length, null);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAutoDemo());
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _advanceTimer?.cancel();
    AudioService.instance.stopAll();
    super.dispose();
  }

  void _scheduleAutoDemo() {
    if (_reduceMotion) return;
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(milliseconds: 500), () {
      if (_phase == _Phase.draw && (_boardKey.currentState?.totalPoints ?? 0) == 0) {
        _boardKey.currentState?.startDemo();
      }
    });
  }

  void _onStrokeChanged(double hitFraction, int totalPoints) {
    final shouldEnable = totalPoints > 0;
    if (shouldEnable != _doneEnabled) setState(() => _doneEnabled = shouldEnable);
  }

  void _onPointerUp() {
    final board = _boardKey.currentState;
    if (board == null || _phase != _Phase.draw) return;
    if (board.hitFraction >= 0.96) {
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 700), _finishItem);
    }
  }

  void _finishItem() {
    final board = _boardKey.currentState;
    if (_phase != _Phase.draw || board == null || board.totalPoints == 0) return;
    _autoTimer?.cancel();
    board.stopDemo();

    final result = evaluateTrace(_item, board.strokes);
    final stars = starsForScore(result.score);
    final left = widget.set.items.length - _round - 1;

    String msg;
    if (result.coverage < 0.45) {
      msg = 'Go all the way around!';
    } else if (stars == 3) {
      msg = 'Perfect ${_item.label.toLowerCase()}!';
    } else if (stars == 2) {
      msg = 'Great job!';
    } else {
      msg = 'Nice try!';
    }

    setState(() {
      _scores[_round] = result.score;
      _lastScore = result.score;
      _lastStars = stars;
      _lastMessage = msg;
      _lastSubline = left == 0 ? 'That was the last one!' : '$left more to go';
      _phase = _Phase.result;
      _doneEnabled = false;
    });
    AudioService.instance.playSfx(stars >= 2 ? 'correct.mp3' : 'wrong.mp3');
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(seconds: 3), _advance);
  }

  void _advance() {
    if (_phase != _Phase.result) return;
    _advanceTimer?.cancel();
    final next = _round + 1;
    if (next >= widget.set.items.length) {
      _showFinal();
      return;
    }
    setState(() {
      _round = next;
      _phase = _Phase.draw;
    });
    _boardKey.currentState?.clear();
    _scheduleAutoDemo();
  }

  Future<void> _showFinal() async {
    final items = widget.set.items;
    final sum = _scores.fold<int>(0, (s, v) => s + (v ?? 0));
    final avg = (sum / items.length).round();
    final prevBest = await TraceBestScoreService.instance.getBest(widget.set.id);
    final isNewBest = await TraceBestScoreService.instance.saveIfBest(widget.set.id, avg);
    final stars = starsForScore(avg);
    if (!mounted) return;
    setState(() {
      _phase = _Phase.recap;
      _finalAvg = avg;
      _finalStars = stars;
      _finalMessage =
          stars == 3 ? 'Amazing tracing!' : (stars == 2 ? 'Great job!' : 'Good try! Play again?');
      _finalBestLine =
          isNewBest ? 'New best score!' : 'Best: ${avg > prevBest ? avg : prevBest}%';
    });
    AudioService.instance.playSfx('win_fanfare.mp3');
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) AudioService.instance.playSfx('cheer.mp3');
    });
  }

  void _restartItem() {
    if (_phase == _Phase.recap) return;
    _autoTimer?.cancel();
    _advanceTimer?.cancel();
    setState(() {
      _scores[_round] = null;
      _phase = _Phase.draw;
      _doneEnabled = false;
    });
    _boardKey.currentState?.clear();
    _scheduleAutoDemo();
  }

  void _replayAll() {
    setState(() {
      _round = 0;
      _scores = List<int?>.filled(widget.set.items.length, null);
      _phase = _Phase.draw;
      _doneEnabled = false;
    });
    _boardKey.currentState?.clear();
    _scheduleAutoDemo();
  }

  void _showMe() {
    if (_phase == _Phase.recap) return;
    if (_phase == _Phase.result) _restartItem();
    _boardKey.currentState?.startDemo();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.set.items;
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                children: [
                  AppHeader(title: widget.set.name, onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 4),
                  if (_phase != _Phase.recap)
                    ProgressDots(
                      total: items.length,
                      currentIndex: _round,
                      activeColor: AppColors.modeDrawPurple,
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(AppTheme.categoryCardRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TracingBoard(
                              key: _boardKey,
                              item: _item,
                              enabled: _phase == _Phase.draw,
                              onStrokeChanged: _onStrokeChanged,
                              onPointerUp: _onPointerUp,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 18,
                          child: IgnorePointer(
                            child: Text(
                              '${widget.set.tagLabel(_item)}  ${_round + 1}/${items.length}',
                              style: const TextStyle(
                                fontFamily: AppTheme.headingFontFamily,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        if (_phase == _Phase.result) _buildResultOverlay(),
                        if (_phase == _Phase.recap) _buildFinalOverlay(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_phase != _Phase.recap) _buildBottomBar(),
                ],
              ),
            ),
            const SoundToggleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final canEdit = _phase == _Phase.draw || _phase == _Phase.result;
    return Row(
      children: [
        _SmallActionButton(
          icon: Icons.refresh_rounded,
          label: 'Clear',
          enabled: canEdit,
          onTap: _restartItem,
        ),
        const SizedBox(width: 12),
        _SmallActionButton(
          icon: Icons.play_arrow_rounded,
          label: 'Show me',
          enabled: canEdit,
          onTap: _showMe,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DoneButton(
            enabled: _doneEnabled && _phase == _Phase.draw,
            onTap: _finishItem,
          ),
        ),
      ],
    );
  }

  Widget _buildResultOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.95),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StarRow(filled: _lastStars),
            const SizedBox(height: 4),
            _CountUpPercent(value: _lastScore, fontSize: 72),
            const SizedBox(height: 8),
            Text(
              _lastMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.boldHeadingFontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _lastSubline,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _round + 1 >= widget.set.items.length ? 'See my score' : 'Next',
              icon: Icons.arrow_forward_rounded,
              color: AppColors.modeDrawPurple,
              onPressed: _advance,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalOverlay() {
    final items = widget.set.items;
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.95),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StarRow(filled: _finalStars),
              const SizedBox(height: 4),
              _CountUpPercent(value: _finalAvg, fontSize: 56),
              const SizedBox(height: 8),
              Text(
                _finalMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.boldHeadingFontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _RecapTile(set: widget.set, item: items[i], score: _scores[i] ?? 0),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _finalBestLine,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  PrimaryButton(
                    label: 'Play again',
                    icon: Icons.refresh_rounded,
                    color: AppColors.modeDrawPurple,
                    onPressed: _replayAll,
                  ),
                  PrimaryButton(
                    label: 'All games',
                    icon: Icons.home_rounded,
                    color: AppColors.brandTeal,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EaseOutCubic extends Curve {
  const _EaseOutCubic();
  @override
  double transformInternal(double t) => 1 - math.pow(1 - t, 3).toDouble();
}

/// A 0 to [value] count-up, re-triggered whenever [value] changes — the
/// Dart equivalent of the prototype's `countUp()`.
class _CountUpPercent extends StatelessWidget {
  final int value;
  final double fontSize;
  const _CountUpPercent({required this.value, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: const _EaseOutCubic(),
      builder: (context, v, _) => Text(
        '${v.round()}%',
        style: TextStyle(
          fontFamily: AppTheme.boldHeadingFontFamily,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int filled; // 0-3
  const _StarRow({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final on = i < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            on ? Icons.star_rounded : Icons.star_border_rounded,
            color: on ? AppColors.traceHit : AppColors.traceDot.withOpacity(0.5),
            size: 56,
          ),
        );
      }),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _DoneButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.correctGreen : AppColors.correctGreen.withOpacity(0.4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_rounded, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Done',
              style: TextStyle(
                fontFamily: AppTheme.boldHeadingFontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tile of the final recap grid — the shape's own outline (or the
/// digit) plus its score, highlighted gold at 80%+.
class _RecapTile extends StatelessWidget {
  final TraceSet set;
  final TraceItem item;
  final int score;
  const _RecapTile({required this.set, required this.item, required this.score});

  @override
  Widget build(BuildContext context) {
    final great = score >= 80;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (set.pipStyle == TracePipStyle.icon)
          SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(painter: _MiniOutlinePainter(item: item, filled: great)),
          )
        else
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: great ? AppColors.traceHit : AppColors.traceTrack,
              border: Border.all(color: AppColors.textPrimary, width: 2),
            ),
            child: Text(
              item.label,
              style: const TextStyle(fontFamily: AppTheme.boldHeadingFontFamily, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        const SizedBox(height: 2),
        Text(
          '$score%',
          style: const TextStyle(fontFamily: AppTheme.boldHeadingFontFamily, fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    );
  }
}

class _MiniOutlinePainter extends CustomPainter {
  final TraceItem item;
  final bool filled;
  const _MiniOutlinePainter({required this.item, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.shortestSide * 0.42;
    final fill = Paint()
      ..color = filled ? AppColors.traceHit : AppColors.traceTrack
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    for (final pl in item.polylines) {
      if (pl.points.isEmpty) continue;
      final path = Path()..moveTo(cx + pl.points.first.u * r, cy + pl.points.first.v * r);
      for (var i = 1; i < pl.points.length; i++) {
        path.lineTo(cx + pl.points[i].u * r, cy + pl.points[i].v * r);
      }
      if (pl.closed) path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniOutlinePainter oldDelegate) => oldDelegate.filled != filled;
}
