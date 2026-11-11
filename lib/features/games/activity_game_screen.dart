import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'activity.dart';
import 'activity_rounds.dart';
import '../../data/repositories/game_session_repository.dart';

/// Offline five-round learning loop for the catalogue's choice-based games.
///
/// Every activity supplies its own learning prompt, visual cue, answer set and
/// explanation. Drag-and-drop activities use dedicated game screens.
class ActivityGameScreen extends StatefulWidget {
  const ActivityGameScreen({
    required this.activity,
    required this.sessionRepository,
    super.key,
  });

  final Activity activity;
  final GameSessionRepository sessionRepository;

  @override
  State<ActivityGameScreen> createState() => _ActivityGameScreenState();
}

class _ActivityGameScreenState extends State<ActivityGameScreen> {
  late final List<ActivityRound> _rounds =
      activityRoundsFor(widget.activity.id);
  int _round = 0;
  int _score = 0;
  int? _answer;
  bool _paused = false;
  bool _finished = false;
  bool _saving = false;
  bool _saveError = false;

  ActivityRound get _currentRound => _rounds[_round];

  void _choose(int index) {
    if (_answer != null || _paused || _finished) return;
    setState(() {
      _answer = index;
      if (index == _currentRound.correctIndex) _score++;
    });
  }

  Future<void> _next() async {
    if (_round == _rounds.length - 1) {
      setState(() {
        _finished = true;
        _saving = true;
        _saveError = false;
      });
      final completedAt = DateTime.now();
      try {
        await widget.sessionRepository.recordSession(
          GameSession(
            id: '${widget.activity.id}_${completedAt.microsecondsSinceEpoch}',
            activityId: widget.activity.id,
            score: _score,
            totalRounds: _rounds.length,
            completedAt: completedAt,
          ),
        );
      } on Object {
        if (mounted) setState(() => _saveError = true);
      } finally {
        if (mounted) setState(() => _saving = false);
      }
      return;
    }
    setState(() {
      _round++;
      _answer = null;
    });
  }

  void _restart() {
    setState(() {
      _round = 0;
      _score = 0;
      _answer = null;
      _paused = false;
      _finished = false;
      _saving = false;
      _saveError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.activity.title)),
        body: const Center(
          child: Text('This learning activity is being prepared.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text(widget.activity.title),
        actions: [
          if (!_finished)
            IconButton(
              tooltip: _paused ? 'Resume game' : 'Pause game',
              onPressed: () => setState(() => _paused = !_paused),
              icon: Icon(
                _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _finished
            ? _result()
            : _paused
                ? _pause()
                : _play(),
      ),
    );
  }

  Widget _play() {
    final round = _currentRound;
    final answered = _answer != null;
    final isCorrect = answered && _answer == round.correctIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: (_round + 1) / _rounds.length,
                    backgroundColor: Colors.white,
                    color: AppTheme.violet,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_round + 1}/${_rounds.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(widget.activity.colorValue), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(
                  widget.activity.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  round.cue,
                  key: const Key('round_cue'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  round.prompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _activityAnswerArea(round, answered),
          if (answered) ...[
            const SizedBox(height: 18),
            Text(
              isCorrect ? 'Amazing! ⭐' : 'Good try! Keep learning 💛',
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
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _next,
              child: Text(
                _round == _rounds.length - 1 ? 'See my score' : 'Next',
              ),
            ),
          ],
        ],
      ),
    );
  }


  /// Uses hands-on interactions for activities where a tap-only quiz is not
  /// the intended learning action. Every interaction still resolves through
  /// [_choose], preserving scoring and session persistence.
  Widget _activityAnswerArea(ActivityRound round, bool answered) {
    const dragActivities = {
      'complete_picture',
      'shadow_matching',
      'color_matching',
      'alphabet_matching',
      'big_small',
      'missing_shapes',
    };

    if (widget.activity.id == 'find_differences') {
      final symbols = round.cue
          .split(RegExp(r'\\s+'))
          .where((symbol) => symbol.isNotEmpty)
          .toList(growable: false);
      return Row(
        children: List.generate(round.options.length, (index) {
          final selected = _answer == index;
          final symbol = index < symbols.length
              ? symbols[index]
              : round.options[index].emoji;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                button: true,
                label: 'Item ${index + 1}',
                child: Material(
                  color: selected ? const Color(0xFFFFE9E5) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    key: Key('answer_$index'),
                    borderRadius: BorderRadius.circular(18),
                    onTap: answered ? null : () => _choose(index),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 92),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? AppTheme.violet
                              : const Color(0xFFE7EAF2),
                          width: selected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(symbol, style: const TextStyle(fontSize: 28)),
                          Text('${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }

    if (dragActivities.contains(widget.activity.id)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DragTarget<int>(
            onWillAcceptWithDetails: (details) =>
                !answered && details.data >= 0 &&
                details.data < round.options.length,
            onAcceptWithDetails: (details) => _choose(details.data),
            builder: (context, candidates, rejected) {
              final hovering = candidates.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minHeight: 104),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hovering
                      ? const Color(0xFFE2F6EA)
                      : Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: hovering ? Colors.green : AppTheme.violet,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      answered ? 'Piece placed!' : 'Drag the answer here',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: round.options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              final option = round.options[index];
              final selected = _answer == index;
              final card = Container(
                key: Key('answer_$index'),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE2F6EA) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? Colors.green : const Color(0xFFE7EAF2),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(option.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              );
              if (answered) return card;
              return Draggable<int>(
                data: index,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(width: 145, child: card),
                ),
                childWhenDragging: Opacity(opacity: 0.25, child: card),
                child: Semantics(
                  label: 'Drag ${option.label} to the answer area',
                  child: card,
                ),
              );
            },
          ),
        ],
      );
    }

    if (widget.activity.id == 'magic_counting') {
      final object = round.cue
          .split(RegExp(r'\\s+'))
          .where((symbol) => symbol.isNotEmpty)
          .first;
      final count = round.cue
          .split(RegExp(r'\\s+'))
          .where((symbol) => symbol == object)
          .length;
      return Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(count, (index) {
              return Semantics(
                label: 'Countable object ${index + 1}',
                child: Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(object, style: const TextStyle(fontSize: 32)),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          const Text('Touch each object, then choose the total.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _standardAnswerGrid(round, answered),
        ],
      );
    }

    return _standardAnswerGrid(round, answered);
  }

  Widget _standardAnswerGrid(ActivityRound round, bool answered) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: round.options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.28,
      ),
      itemBuilder: (context, index) {
        final option = round.options[index];
        final selected = _answer == index;
        final correct = index == round.correctIndex;
        final color = answered && selected
            ? (correct ? const Color(0xFFE2F6EA) : const Color(0xFFFFE9E5))
            : Colors.white;
        final borderColor = selected
            ? (correct ? Colors.green : Colors.deepOrange)
            : answered && correct
                ? Colors.green
                : const Color(0xFFE7EAF2);
        return Material(
          color: color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            key: Key('answer_$index'),
            borderRadius: BorderRadius.circular(20),
            onTap: answered ? null : () => _choose(index),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: selected || (answered && correct) ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(option.emoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 5),
                  Text(option.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pause() => Center(
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
              onPressed: () => setState(() => _paused = false),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
            ),
          ],
        ),
      );

  Widget _result() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 76)),
              const SizedBox(height: 16),
              Text(
                'Wonderful work!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You got $_score out of ${_rounds.length} correct.',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _saving
                    ? 'Saving your progress…'
                    : _saveError
                        ? 'Progress could not be saved. Please try again.'
                        : 'Progress saved on this device.',
                key: const Key('session_save_status'),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _restart,
                  child: const Text('Play again'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to games'),
              ),
            ],
          ),
        ),
      );
}
