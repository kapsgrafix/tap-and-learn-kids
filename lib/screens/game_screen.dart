import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_category.dart';
import '../models/game_item.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/option_card.dart';
import '../widgets/progress_dots.dart';
import 'result_screen.dart';

const int questionsPerRound = 10;

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

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final correct = question.correct;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    iconSize: 28,
                    icon: const Icon(Icons.home_rounded, color: AppColors.inkText),
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                  Expanded(
                    child: ProgressDots(total: _questions.length, currentIndex: _currentIndex),
                  ),
                  const SizedBox(width: 28), // balances the home icon
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _playCurrentPrompt,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: widget.category.color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        correct.label,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.builder(
                  itemCount: question.options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = question.options[index];
                    final state = _stateFor(item, correct);
                    return OptionCard(
                      item: item,
                      state: state,
                      onTap: state == OptionState.idle ? () => _onOptionTap(item) : null,
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
