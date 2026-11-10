import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class _OddOneOutRound {
  const _OddOneOutRound({
    required this.title,
    required this.instruction,
    required this.items,
    required this.oddIndex,
    required this.explanation,
  });

  final String title;
  final String instruction;
  final List<_OddOneOutItem> items;
  final int oddIndex;
  final String explanation;
}

class _OddOneOutItem {
  const _OddOneOutItem(this.emoji, this.label);

  final String emoji;
  final String label;
}

const _rounds = <_OddOneOutRound>[
  _OddOneOutRound(
    title: 'Find the animal',
    instruction: 'Three friends are animals. Which one is not?',
    items: [
      _OddOneOutItem('🦁', 'Lion'),
      _OddOneOutItem('🐘', 'Elephant'),
      _OddOneOutItem('🚗', 'Car'),
      _OddOneOutItem('🐼', 'Panda'),
    ],
    oddIndex: 2,
    explanation: 'A car is a vehicle. The others are animals.',
  ),
  _OddOneOutRound(
    title: 'Fruit basket',
    instruction: 'Find the one that is not a fruit.',
    items: [
      _OddOneOutItem('🍎', 'Apple'),
      _OddOneOutItem('🍌', 'Banana'),
      _OddOneOutItem('🥕', 'Carrot'),
      _OddOneOutItem('🍇', 'Grapes'),
    ],
    oddIndex: 2,
    explanation: 'A carrot is a vegetable. The others are fruits.',
  ),
  _OddOneOutRound(
    title: 'Things that fly',
    instruction: 'Which one cannot fly in the sky?',
    items: [
      _OddOneOutItem('✈️', 'Airplane'),
      _OddOneOutItem('🦋', 'Butterfly'),
      _OddOneOutItem('🐟', 'Fish'),
      _OddOneOutItem('🐦', 'Bird'),
    ],
    oddIndex: 2,
    explanation: 'A fish swims in water. The others can fly.',
  ),
  _OddOneOutRound(
    title: 'Shape party',
    instruction: 'Find the shape with no corners.',
    items: [
      _OddOneOutItem('🔺', 'Triangle'),
      _OddOneOutItem('🟦', 'Square'),
      _OddOneOutItem('🟠', 'Circle'),
      _OddOneOutItem('⭐', 'Star'),
    ],
    oddIndex: 2,
    explanation: 'A circle has no corners. The others have corners.',
  ),
  _OddOneOutRound(
    title: 'Getting dressed',
    instruction: 'Which one do we not wear?',
    items: [
      _OddOneOutItem('👕', 'Shirt'),
      _OddOneOutItem('👟', 'Shoes'),
      _OddOneOutItem('🧢', 'Cap'),
      _OddOneOutItem('🥣', 'Bowl'),
    ],
    oddIndex: 3,
    explanation: 'A bowl is for eating. The others are clothes.',
  ),
];

class OddOneOutGameScreen extends StatefulWidget {
  const OddOneOutGameScreen({super.key});

  @override
  State<OddOneOutGameScreen> createState() => _OddOneOutGameScreenState();
}

class _OddOneOutGameScreenState extends State<OddOneOutGameScreen> {
  int _roundIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _finished = false;

  _OddOneOutRound get _round => _rounds[_roundIndex];
  bool get _isCorrect => _selectedIndex == _round.oddIndex;

  void _select(int index) {
    if (_selectedIndex != null || _finished) return;
    setState(() {
      _selectedIndex = index;
      if (index == _round.oddIndex) _score++;
    });
  }

  void _next() {
    setState(() {
      if (_roundIndex == _rounds.length - 1) {
        _finished = true;
      } else {
        _roundIndex++;
        _selectedIndex = null;
      }
    });
  }

  void _restart() {
    setState(() {
      _roundIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Odd One Out'),
        leading: IconButton(
          tooltip: 'Back to games',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: _finished ? _result() : _game(),
      ),
    );
  }

  Widget _game() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: (_roundIndex + 1) / _rounds.length,
                    minHeight: 10,
                    backgroundColor: Colors.white,
                    color: AppTheme.violet,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_roundIndex + 1}/${_rounds.length}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD98A), Color(0xFFFFF0C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                const Text('🕵️', style: TextStyle(fontSize: 58)),
                const SizedBox(height: 10),
                Text(
                  _round.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  _round.instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _round.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) {
              final item = _round.items[index];
              final answered = _selectedIndex != null;
              final selected = _selectedIndex == index;
              final isOdd = index == _round.oddIndex;
              final showCorrect = answered && isOdd;
              final color = selected
                  ? (isOdd ? const Color(0xFFE2F6EA) : const Color(0xFFFFE9E5))
                  : Colors.white;
              return Material(
                color: color,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  key: Key('odd_option_$index'),
                  borderRadius: BorderRadius.circular(22),
                  onTap: answered ? null : () => _select(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? (isOdd ? Colors.green : Colors.deepOrange)
                            : showCorrect
                                ? Colors.green
                                : const Color(0xFFE7EAF2),
                        width: selected || showCorrect ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedIndex != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? const Color(0xFFE5F7EE)
                    : const Color(0xFFFFECE7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    _isCorrect ? 'Brilliant spotting! ⭐' : 'Good try! 💛',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(_round.explanation, textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _next,
              child: Text(
                _roundIndex == _rounds.length - 1 ? 'See my score' : 'Next puzzle',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _result() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 76)),
            const SizedBox(height: 14),
            Text('Amazing detective!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'You spotted $_score out of ${_rounds.length} odd ones.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
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
}
