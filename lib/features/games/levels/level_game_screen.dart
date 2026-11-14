import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../data/repositories/game_session_repository.dart';
import '../../../data/repositories/level_progress_repository.dart';
import '../activity.dart';
import 'game_level.dart';
import 'game_token_view.dart';
import 'level_generator.dart';
import 'level_result_recorder.dart';
import 'level_result_view.dart';
import 'level_round.dart';

/// Plays one generated level of a question-based game.
class LevelGameScreen extends StatefulWidget {
  const LevelGameScreen({
    required this.activity,
    required this.level,
    required this.sessionRepository,
    required this.progressRepository,
    required this.onNextLevel,
    this.grade,
    super.key,
  });

  final Activity activity;
  final int level;
  final String? grade;
  final GameSessionRepository sessionRepository;
  final LevelProgressRepository progressRepository;

  /// Opens the next level (replacing this screen).
  final ValueChanged<int> onNextLevel;

  @override
  State<LevelGameScreen> createState() => _LevelGameScreenState();
}

class _LevelGameScreenState extends State<LevelGameScreen>
    with WidgetsBindingObserver {
  late final List<LevelRound> _rounds = generateLevel(
    widget.activity.id,
    widget.level,
    grade: widget.grade,
  );
  late final LevelResultRecorder _recorder = LevelResultRecorder(
    activityId: widget.activity.id,
    level: widget.level,
    sessionRepository: widget.sessionRepository,
    progressRepository: widget.progressRepository,
  );

  int _roundIndex = 0;
  int _score = 0;
  int? _answer;
  int? _wrongTap;
  final List<int> _ordered = [];
  bool _orderMistake = false;
  bool _roundDone = false;
  bool _paused = false;
  bool _finished = false;
  bool _saving = false;
  bool _saveError = false;
  Timer? _advanceTimer;

  LevelRound get _round => _rounds[_roundIndex];
  bool get _roundCorrect => _round.interaction == RoundInteraction.order
      ? !_orderMistake
      : _answer == _round.correctIndex;
  int get _stars => starsFor(_score, _rounds.length);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_finished && !_paused) {
      _setPaused(true);
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _play(GameSound sound) =>
      unawaited(AppServices.of(context).sounds.play(sound));

  void _setPaused(bool paused) {
    setState(() => _paused = paused);
    if (paused) {
      _advanceTimer?.cancel();
    } else if (_roundDone && _roundCorrect) {
      _scheduleAdvance();
    }
  }

  void _choose(int index) {
    if (_roundDone || _paused || _finished) return;
    final correct = index == _round.correctIndex;
    setState(() {
      _answer = index;
      _roundDone = true;
      if (correct) _score++;
    });
    _play(correct ? GameSound.correct : GameSound.wrong);
    if (correct) _scheduleAdvance();
  }

  void _tapInOrder(int index) {
    if (_roundDone || _paused || _ordered.contains(index)) return;
    final expected = _round.orderSolution[_ordered.length];
    if (index != expected) {
      setState(() {
        _orderMistake = true;
        _wrongTap = index;
      });
      _play(GameSound.wrong);
      return;
    }
    setState(() {
      _ordered.add(index);
      _wrongTap = null;
    });
    if (_ordered.length == _round.options.length) {
      setState(() {
        _roundDone = true;
        if (!_orderMistake) _score++;
      });
      _play(_orderMistake ? GameSound.wrong : GameSound.correct);
      if (!_orderMistake) _scheduleAdvance();
    } else {
      _play(GameSound.tap);
    }
  }

  void _scheduleAdvance() {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted && !_paused) _next();
    });
  }

  void _next() {
    _advanceTimer?.cancel();
    if (!_roundDone) return;
    if (_roundIndex == _rounds.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _roundIndex++;
      _answer = null;
      _wrongTap = null;
      _ordered.clear();
      _orderMistake = false;
      _roundDone = false;
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    setState(() => _finished = true);
    _play(_stars > 0 ? GameSound.levelComplete : GameSound.wrong);
    await _save();
  }

  /// Saves once; retry reuses the same session id so nothing duplicates.
  Future<void> _save() async {
    if (_saving || _recorder.saved) return;
    setState(() {
      _saving = true;
      _saveError = false;
    });
    try {
      await _recorder.save(score: _score, total: _rounds.length, stars: _stars);
    } on Object {
      if (mounted) setState(() => _saveError = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text('${widget.activity.title} · Level ${widget.level}'),
        actions: [
          if (!_finished)
            IconButton(
              tooltip: _paused ? 'Resume game' : 'Pause game',
              onPressed: () => _setPaused(!_paused),
              icon: Icon(
                _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _finished
            ? LevelResultView(
                level: widget.level,
                score: _score,
                total: _rounds.length,
                stars: _stars,
                saving: _saving,
                saveError: _saveError,
                onRetrySave: _save,
                onReplay: () => widget.onNextLevel(widget.level),
                onNextLevel: _stars > 0 && widget.level < kLevelsPerGame
                    ? () => widget.onNextLevel(widget.level + 1)
                    : null,
                onLevelMap: () => Navigator.of(context).maybePop(),
              )
            : _paused
            ? _pauseView()
            : _playView(),
      ),
    );
  }

  Widget _pauseView() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⏸️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text(
          'Take a little break',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const Key('resume_button'),
          onPressed: () => _setPaused(false),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Resume'),
        ),
      ],
    ),
  );

  Widget _playView() {
    final round = _round;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 560.0);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: ListView(
              key: ValueKey('round_$_roundIndex'),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _RoundProgress(
                  round: _roundIndex,
                  total: _rounds.length,
                  score: _score,
                ),
                const SizedBox(height: 14),
                _questionCard(round, width - 36),
                const SizedBox(height: 16),
                _answerArea(round, width - 36),
                if (_roundDone) ...[
                  const SizedBox(height: 16),
                  _feedback(round),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _questionCard(LevelRound round, double width) {
    final drag = round.interaction == RoundInteraction.drag;
    final hasGap = round.cue.any((t) => t.kind == TokenKind.gap);
    final cueSize = round.cue.isEmpty
        ? 0.0
        : ((width - 40) / round.cue.length - 6).clamp(30.0, 84.0);
    Widget cueToken(GameToken token) {
      final view = GameTokenView(token, size: cueSize);
      if (!drag) return view;
      if (token.kind == TokenKind.gap) {
        return _dropTarget(round, token, cueSize);
      }
      return view;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(widget.activity.colorValue).withValues(alpha: 0.85),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1425365B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            round.prompt,
            key: const Key('round_prompt'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900, height: 1.25),
          ),
          if (round.referenceRow.isNotEmpty) ...[
            const SizedBox(height: 12),
            _rowLabel('Picture 1'),
            _tokenRow(round.referenceRow, width - 32),
            const SizedBox(height: 6),
            _rowLabel('Picture 2 — tap the change below'),
          ],
          if (round.interaction == RoundInteraction.order) ...[
            const SizedBox(height: 14),
            _orderSlots(round, width - 32),
          ],
          if (round.cue.isNotEmpty) ...[
            const SizedBox(height: 14),
            if (drag && !hasGap)
              _dropTarget(round, round.cue.first, cueSize, wrap: true)
            else
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 8,
                children: round.cue.map(cueToken).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _rowLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: Color(0xFF5B6785),
      ),
    ),
  );

  Widget _tokenRow(List<GameToken> tokens, double width) {
    final size = ((width - 8) / tokens.length - 8).clamp(30.0, 60.0);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final token in tokens)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: GameTokenView(token, size: size),
          ),
      ],
    );
  }

  Widget _orderSlots(LevelRound round, double width) {
    final size = ((width - 8) / round.options.length - 8).clamp(36.0, 64.0);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        for (var slot = 0; slot < round.options.length; slot++)
          Container(
            key: Key('order_slot_$slot'),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: slot < _ordered.length
                  ? const Color(0xFFE2F6EA)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: slot < _ordered.length
                    ? const Color(0xFF2E9E5B)
                    : const Color(0xFFCBD2E1),
                width: 2,
              ),
            ),
            child: slot < _ordered.length
                ? FittedBox(
                    child: GameTokenView(
                      round.options[_ordered[slot]],
                      size: size * 0.8,
                    ),
                  )
                : Text(
                    '${slot + 1}',
                    style: const TextStyle(
                      color: Color(0xFFA3ACC2),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _dropTarget(
    LevelRound round,
    GameToken token,
    double size, {
    bool wrap = false,
  }) {
    return DragTarget<int>(
      key: const Key('drop_target'),
      onWillAcceptWithDetails: (details) => !_roundDone && !_paused,
      onAcceptWithDetails: (details) => _choose(details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        final placed = _roundDone && _answer != null;
        final shown = placed ? round.options[_answer!] : token;
        final view = GameTokenView(shown, size: size, highlightGap: hovering);
        if (!wrap) return view;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hovering
                ? const Color(0xFFE2F6EA)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hovering ? const Color(0xFF2E9E5B) : AppTheme.violet,
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameTokenView(token, size: size),
              if (!_roundDone)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Drop here',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.violet,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _answerArea(LevelRound round, double width) {
    final count = round.options.length;
    final columns = round.interaction == RoundInteraction.spotInRow
        ? math.min(count, 4)
        : count == 4
        ? 2
        : 3;
    const spacing = 12.0;
    final tile = (width - spacing * (columns - 1)) / columns;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (var i = 0; i < count; i++)
          SizedBox(width: tile, child: _optionTile(round, i, tile)),
      ],
    );
  }

  Widget _optionTile(LevelRound round, int index, double tile) {
    final token = round.options[index];
    final order = round.interaction == RoundInteraction.order;
    final placed = order && _ordered.contains(index);
    final isAnswer = !order && _answer == index;
    final reveal = _roundDone && !order && index == round.correctIndex;
    final wrong =
        (isAnswer && index != round.correctIndex) ||
        (order && _wrongTap == index);
    final background = reveal || placed
        ? const Color(0xFFE2F6EA)
        : wrong
        ? const Color(0xFFFFE9E5)
        : Colors.white;
    final border = reveal || placed
        ? const Color(0xFF2E9E5B)
        : wrong
        ? const Color(0xFFE5602E)
        : const Color(0xFFE3E7F0);
    final showLabel = round.showOptionLabels && token.kind == TokenKind.emoji;
    final tokenSize = math.min(64.0, tile * 0.55);

    final card = AnimatedContainer(
      duration: AppServices.reduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      constraints: BoxConstraints(minHeight: math.max(72, tile * 0.82)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: reveal || wrong ? 3 : 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F25365B),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: GameTokenView(
              token,
              size: tokenSize,
              excludeSemantics: true,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Text(
              token.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
          ],
        ],
      ),
    );

    final enabled = !_roundDone && !_paused && !placed;
    final onTap = !enabled
        ? null
        : order
        ? () => _tapInOrder(index)
        : () => _choose(index);
    final semanticLabel = round.interaction == RoundInteraction.spotInRow
        ? 'Item ${index + 1}: ${token.accessibleLabel}'
        : token.accessibleLabel;

    final tappable = Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      hint: round.interaction == RoundInteraction.drag
          ? 'Double tap to choose, or drag to the gap'
          : null,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('answer_$index'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: card,
        ),
      ),
    );
    if (round.interaction != RoundInteraction.drag || !enabled) {
      return tappable;
    }
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: tile, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: tappable,
    );
  }

  Widget _feedback(LevelRound round) {
    final correct = _roundCorrect;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFE9F8EF) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            correct ? 'Amazing! ⭐' : 'Good try! Here is the answer 💛',
            key: const Key('round_feedback'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            round.explanation,
            key: const Key('answer_explanation'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('next_round_button'),
            onPressed: _next,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              _roundIndex == _rounds.length - 1 ? 'See my stars' : 'Next',
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundProgress extends StatelessWidget {
  const _RoundProgress({
    required this.round,
    required this.total,
    required this.score,
  });

  final int round;
  final int total;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (round + 1) / total),
              duration: AppServices.reduceMotion(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 350),
              builder: (context, value, _) => LinearProgressIndicator(
                minHeight: 12,
                value: value,
                backgroundColor: Colors.white,
                color: AppTheme.violet,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${round + 1}/$total',
          key: const Key('round_counter'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 10),
        Text('⭐ $score', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
