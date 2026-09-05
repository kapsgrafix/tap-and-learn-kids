import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../models/game_item.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/option_card.dart';
import '../widgets/progress_dots.dart';
import '../widgets/sound_toggle_button.dart';
import 'result_screen.dart';

const int questionsPerRound = 8;

class _Question {
  final GameItem correct;
  final List<GameItem> options;
  _Question({required this.correct, required this.options});
}

class GameScreen extends StatefulWidget {
  final GameCategory category;
  const GameScreen({super.key, required this.category});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<_Question> _questions;
  int _currentIndex = 0;
  bool _answeredCorrectly = false;
  final Set<String> _wrongTappedIds = {};
  int _perfectCount = 0; // answered correctly on the first try

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions(widget.category);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrentPrompt());
  }

  @override
  void dispose() {
    AudioService.instance.stopAll();
    super.dispose();
  }

  List<_Question> _buildQuestions(GameCategory category) {
    final rand = Random();
    final pool = List<GameItem>.from(category.items)..shuffle(rand);

    final targets = <GameItem>[];
    if (pool.length >= questionsPerRound) {
      targets.addAll(pool.take(questionsPerRound));
    } else {
      // Small category: cycle through a re-shuffled pool until we have enough.
      while (targets.length < questionsPerRound) {
        final batch = List<GameItem>.from(category.items)..shuffle(rand);
        targets.addAll(batch);
      }
      targets.removeRange(questionsPerRound, targets.length);
    }

    return targets.map((correct) {
      final distractorsPool = category.items.where((i) => i.id != correct.id).toList()..shuffle(rand);
      final distractors = distractorsPool.take(3).toList();
      final options = [correct, ...distractors]..shuffle(rand);
      return _Question(correct: correct, options: options);
    }).toList();
  }

  void _playCurrentPrompt() {
    AudioService.instance.playWord(_questions[_currentIndex].correct.audioAsset);
  }

  void _onOptionTap(GameItem tapped) {
    if (_answeredCorrectly) return;
    final correct = _questions[_currentIndex].correct;

    if (tapped.id == correct.id) {
      setState(() => _answeredCorrectly = true);
      AudioService.instance.playSfx('correct.mp3');
      if (_wrongTappedIds.isEmpty) _perfectCount++;
      Future.delayed(const Duration(milliseconds: 900), _goToNext);
    } else {
      if (_wrongTappedIds.contains(tapped.id)) return;
      setState(() => _wrongTappedIds.add(tapped.id));
      AudioService.instance.playSfx('wrong.mp3');
    }
  }

  void _goToNext() {
    if (!mounted) return;
    if (_currentIndex >= _questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            category: widget.category,
            perfectCount: _perfectCount,
            total: _questions.length,
          ),
        ),
      );
      return;
    }
    setState(() {
      _currentIndex++;
      _answeredCorrectly = false;
      _wrongTappedIds.clear();
    });
    _playCurrentPrompt();
  }

  OptionState _stateFor(GameItem item, GameItem correct) {
    if (_answeredCorrectly) {
      if (item.id == correct.id) return OptionState.correct;
      return OptionState.disabled;
    }
    if (_wrongTappedIds.contains(item.id)) return OptionState.wrong;
    return OptionState.idle;
  }

  Widget _buildAnswerRow(List<GameItem> items, GameItem correct) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(
            child: AspectRatio(
              aspectRatio: 163 / 155,
              child: OptionCard(
                item: items[i],
                state: _stateFor(items[i], correct),
                onTap: _stateFor(items[i], correct) == OptionState.idle
                    ? () => _onOptionTap(items[i])
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final correct = question.correct;
    final options = question.options;

    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  AppHeader(
                    title: widget.category.name,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // PromptCard: the word + tap-to-hear-again sound icon.
                          GestureDetector(
                            onTap: _playCurrentPrompt,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(28, 22, 24, 22),
                              decoration: BoxDecoration(
                                color: widget.category.color,
                                borderRadius: BorderRadius.circular(AppTheme.promptCardRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.category.color.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    correct.label,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.headingFontFamily,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textInverse,
                                    ),
                                  ),
                                  const Icon(Icons.volume_up_rounded, color: AppColors.textInverse, size: 26),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // AnswerGrid: 2x2 illustrated option cards.
                          _buildAnswerRow(options.sublist(0, 2), correct),
                          const SizedBox(height: 16),
                          _buildAnswerRow(options.sublist(2, 4), correct),
                          const SizedBox(height: 28),
                          // PaginationRow.
                          ProgressDots(
                            total: _questions.length,
                            currentIndex: _currentIndex,
                            activeColor: widget.category.color,
                          ),
                        ],
                      ),
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
