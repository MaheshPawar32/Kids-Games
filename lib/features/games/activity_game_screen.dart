import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'activity.dart';
import 'activity_rounds.dart';

/// Offline five-round learning loop for the catalogue's choice-based games.
///
/// Every activity supplies its own learning prompt, visual cue, answer set and
/// explanation. Drag-and-drop activities use dedicated game screens.
class ActivityGameScreen extends StatefulWidget {
  const ActivityGameScreen({required this.activity, super.key});

  final Activity activity;

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

  ActivityRound get _currentRound => _rounds[_round];

  void _choose(int index) {
    if (_answer != null || _paused || _finished) return;
    setState(() {
      _answer = index;
      if (index == _currentRound.correctIndex) _score++;
    });
  }

  void _next() {
    setState(() {
      if (_round == _rounds.length - 1) {
        _finished = true;
      } else {
        _round++;
        _answer = null;
      }
    });
  }

  void _restart() {
    setState(() {
      _round = 0;
      _score = 0;
      _answer = null;
      _paused = false;
      _finished = false;
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
          GridView.builder(
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
                  ? (correct
                      ? const Color(0xFFE2F6EA)
                      : const Color(0xFFFFE9E5))
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
                        Text(
                          option.emoji,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          option.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
