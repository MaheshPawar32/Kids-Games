import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'activity.dart';

/// A complete offline activity loop shared by the catalogue's short games.
/// Each round has feedback, progression, pause/resume, retry and a result.
class ActivityGameScreen extends StatefulWidget {
  const ActivityGameScreen({required this.activity, super.key});

  final Activity activity;

  @override
  State<ActivityGameScreen> createState() => _ActivityGameScreenState();
}

class _ActivityGameScreenState extends State<ActivityGameScreen> {
  static const _roundCount = 5;
  int _round = 0;
  int _score = 0;
  int? _answer;
  bool _paused = false;
  bool _finished = false;

  List<String> get _options {
    switch (widget.activity.id) {
      case 'alphabet_matching':
        final base = 65 + (_round * 3);
        return List.generate(4, (i) => String.fromCharCode(base + i));
      case 'missing_numbers':
      case 'magic_counting':
      case 'number_sequencing':
        final base = _round + 1;
        return List.generate(4, (i) => '${base + i}');
      case 'color_matching':
        return const ['Red', 'Blue', 'Yellow', 'Green'];
      case 'animal_recognition':
        return const ['Lion', 'Elephant', 'Rabbit', 'Panda'];
      case 'big_small':
        return const ['Big', 'Small', 'Tall', 'Short'];
      case 'shape_matching':
      case 'missing_shapes':
      case 'what_comes_next':
        return const ['Circle', 'Square', 'Triangle', 'Star'];
      default:
        return const ['Piece A', 'Piece B', 'Piece C', 'Piece D'];
    }
  }

  int get _correctIndex {
    switch (widget.activity.id) {
      case 'alphabet_matching':
      case 'missing_numbers':
      case 'magic_counting':
      case 'number_sequencing':
        return 0;
      case 'color_matching':
        return _round % 4;
      case 'animal_recognition':
        return (_round + 1) % 4;
      case 'big_small':
        return _round.isEven ? 0 : 1;
      default:
        return (_round * 2) % 4;
    }
  }

  String get _prompt {
    switch (widget.activity.id) {
      case 'alphabet_matching':
        return 'Which letter comes first?';
      case 'missing_numbers':
        return 'What number comes next?';
      case 'magic_counting':
        return 'How many stars are in this round?';
      case 'number_sequencing':
        return 'Choose the next number in the sequence.';
      case 'color_matching':
        return 'Find the matching color.';
      case 'animal_recognition':
        return 'Which animal is our friendly animal?';
      case 'big_small':
        return 'Choose the size shown by the picture.';
      case 'shape_matching':
      case 'missing_shapes':
      case 'what_comes_next':
        return 'Which shape completes the pattern?';
      default:
        return 'Choose the piece that completes the picture.';
    }
  }

  void _choose(int index) {
    if (_answer != null || _paused || _finished) return;
    setState(() {
      _answer = index;
      if (index == _correctIndex) _score++;
    });
  }

  void _next() {
    setState(() {
      if (_round == _roundCount - 1) {
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
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text(widget.activity.title),
        actions: [
          if (!_finished)
            IconButton(
              tooltip: _paused ? 'Resume game' : 'Pause game',
              onPressed: () => setState(() => _paused = !_paused),
              icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: _finished ? _result() : _paused ? _pause() : _play(),
      ),
    );
  }

  Widget _play() {
    final options = _options;
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
                    value: (_round + 1) / _roundCount,
                    backgroundColor: Colors.white,
                    color: AppTheme.violet,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_round + 1}/$_roundCount',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
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
                Text(widget.activity.emoji, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                Text(_prompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final selected = _answer == index;
              final correct = index == _correctIndex;
              final answered = _answer != null;
              final color = answered && selected
                  ? (correct ? const Color(0xFFE2F6EA) : const Color(0xFFFFE9E5))
                  : Colors.white;
              return Material(
                color: color,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  key: Key('answer_$index'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: answered ? null : () => _choose(index),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? (correct ? Colors.green : Colors.deepOrange)
                            : const Color(0xFFE7EAF2),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(options[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                ),
              );
            },
          ),
          if (_answer != null) ...[
            const SizedBox(height: 18),
            Text(
              _answer == _correctIndex ? 'Amazing! ⭐' : 'Good try! Keep learning 💛',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _next,
              child: Text(_round == _roundCount - 1 ? 'See my score' : 'Next'),
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
            Text('Take a little break',
                style: Theme.of(context).textTheme.headlineSmall),
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
              Text('Wonderful work!',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('You got $_score out of $_roundCount correct.',
                  style: const TextStyle(fontSize: 18)),
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
