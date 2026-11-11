import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnWorldsScreen extends StatefulWidget {
  const LearnWorldsScreen({super.key});

  @override
  State<LearnWorldsScreen> createState() => _LearnWorldsScreenState();
}

class _LearnWorldsScreenState extends State<LearnWorldsScreen> {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  Set<String> _completed = <String>{};
  bool _loading = true;

  static const _worlds = <_LearnWorld>[
    _LearnWorld('letters', 'Alphabet & Phonics',
        'Letters, first sounds and words', '🔤', Color(0xFFFFE8AF), [
      _LearnLesson('letter_a', 'The letter A', '🍎',
          'A is the first letter of the alphabet. Apple begins with A.',
          'Say the sound, trace the letter in the air, then find its picture.', [
        _LearnQuestion('Which word begins with A?', ['Apple', 'Ball', 'Cat'], 0),
        _LearnQuestion('Find the letter A.', ['B', 'A', 'C'], 1),
        _LearnQuestion('Which picture matches A?', ['🐶', '🍎', '🐟'], 1),
      ]),
      _LearnLesson('letter_b', 'The letter B', '⚽',
          'B begins words like ball, bat and banana.',
          'Press your lips together gently to make the beginning B sound.', [
        _LearnQuestion('Which word begins with B?', ['Dog', 'Ball', 'Sun'], 1),
        _LearnQuestion('Find the letter B.', ['D', 'P', 'B'], 2),
        _LearnQuestion('Which picture starts with B?', ['🍌', '🍎', '🐘'], 0),
      ]),
    ]),
    _LearnWorld('numbers', 'Numbers & Maths',
        'Counting, comparing and little puzzles', '🔢', Color(0xFFDDF4FF), [
      _LearnLesson('count_to_five', 'Count to five', '⭐',
          'Counting helps us know how many things we have. Count each star once.',
          'Point to each object as you count: one, two, three, four, five.', [
        _LearnQuestion('How many stars are here? ⭐ ⭐ ⭐', ['2', '3', '4'], 1),
        _LearnQuestion('What number comes after 2?', ['1', '3', '5'], 1),
        _LearnQuestion('Which group has five dots?', ['● ●', '● ● ●', '● ● ● ● ●'], 2),
      ]),
      _LearnLesson('shapes_count', 'Count the shapes', '🔺',
          'A circle, a triangle and a square are different shapes.',
          'Look carefully at each shape before you count it.', [
        _LearnQuestion('How many sides does a triangle have?', ['2', '3', '4'], 1),
        _LearnQuestion('Which shape has no corners?', ['Circle', 'Square', 'Triangle'], 0),
        _LearnQuestion('Which shape has four equal sides?', ['Circle', 'Square', 'Oval'], 1),
      ]),
    ]),
    _LearnWorld('patterns', 'Shapes & Patterns',
        'Notice what repeats and what comes next', '🔺', Color(0xFFE1F7E9), [
      _LearnLesson('repeat_pattern', 'Find the pattern', '🔵',
          'A pattern is a part that repeats in the same order.',
          'Look at the first two shapes. Then see which shape repeats next.', [
        _LearnQuestion('🔴 🔵 🔴 ?', ['🔵', '🟢', '⭐'], 0),
        _LearnQuestion('⭐ 🌙 ⭐ 🌙 ?', ['🌙', '⭐', '🔺'], 1),
        _LearnQuestion('🟩 🟩 🔴 🟩 🟩 ?', ['🔵', '🔴', '⭐'], 1),
      ]),
    ]),
    _LearnWorld('animals', 'Animals & Nature',
        'Discover animal homes and the natural world', '🦋', Color(0xFFFFE6DE), [
      _LearnLesson('animal_homes', 'Animal homes', '🐝',
          'Bees live in hives and birds build nests. Fish live in water.',
          'Think about what each animal needs to stay safe and find food.', [
        _LearnQuestion('Where does a bird lay its eggs?', ['Nest', 'Hive', 'Pond'], 0),
        _LearnQuestion('Where do fish live?', ['Tree', 'Water', 'Desert'], 1),
        _LearnQuestion('Which animal makes a hive?', ['Bee', 'Lion', 'Rabbit'], 0),
      ]),
      _LearnLesson('animal_food', 'What animals eat', '🥕',
          'Different animals eat different foods. Rabbits enjoy plants and carrots.',
          'Match an animal with food it can eat.', [
        _LearnQuestion('Which food does a rabbit eat?', ['Carrot', 'Stone', 'Soap'], 0),
        _LearnQuestion('What do cows eat?', ['Grass', 'Plastic', 'Metal'], 0),
        _LearnQuestion('Which animal eats fish?', ['Penguin', 'Giraffe', 'Cow'], 0),
      ]),
    ]),
    _LearnWorld('reading', 'Stories & Reading',
        'Read tiny stories and remember what happens', '📚', Color(0xFFEDE5FF), [
      _LearnLesson('tiny_story', 'Mia and the red kite', '🪁',
          'Mia took her red kite to the park. The wind helped it fly high in the sky.',
          'Read the story slowly. Remember who went to the park and what she carried.', [
        _LearnQuestion('Who went to the park?', ['Mia', 'A lion', 'A robot'], 0),
        _LearnQuestion('What color was the kite?', ['Blue', 'Red', 'Green'], 1),
        _LearnQuestion('What helped the kite fly?', ['Rain', 'Wind', 'Snow'], 1),
      ]),
    ]),
    _LearnWorld('science', 'Science Discovery',
        'Explore simple facts about our world', '🔬', Color(0xFFDDF4FF), [
      _LearnLesson('sun_shadow', 'Sun and shadows', '☀️',
          'When an object blocks light, it can make a shadow.',
          'Stand near a light and look at the shadow made by your hand.', [
        _LearnQuestion('What helps make a shadow?', ['Blocked light', 'Music', 'A smell'], 0),
        _LearnQuestion('Where is a shadow easy to see?', ['Bright sunlight', 'Dark cupboard', 'Under a blanket'], 0),
        _LearnQuestion('Can your hand make a shadow?', ['Yes', 'No', 'Only underwater'], 0),
      ]),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final saved = await _preferences.getString('learn_completed_lessons_v1');
      if (!mounted) return;
      setState(() {
        _completed = saved == null
            ? <String>{}
            : saved.split('|').where((id) => id.isNotEmpty).toSet();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finishLesson(String id) async {
    final next = <String>{..._completed, id};
    final sorted = next.toList()..sort();
    try {
      await _preferences.setString(
        'learn_completed_lessons_v1',
        sorted.join('|'),
      );
    } catch (_) {
      // The lesson remains playable even when the device cannot save progress.
    }
    if (mounted) setState(() => _completed = next);
  }

  Future<void> _openLesson(
    BuildContext context,
    _LearnLesson lesson,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _LearnLessonScreen(
          lesson: lesson,
          completed: _completed.contains(lesson.id),
          onCompleted: () => _finishLesson(lesson.id),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final total = _worlds.fold<int>(
      0,
      (sum, world) => sum + world.lessons.length,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Learning worlds',
                              style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 6),
                          const Text(
                            'Explore a short lesson, try a few questions and collect learning stars.',
                          ),
                          const SizedBox(height: 18),
                          _LearnProgressCard(
                            completed: _completed.length,
                            total: total,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    sliver: SliverList.separated(
                      itemCount: _worlds.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final world = _worlds[index];
                        final done = world.lessons
                            .where((lesson) => _completed.contains(lesson.id))
                            .length;
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            key: Key('learn_world_' + world.id),
                            onTap: () => _showWorld(context, world),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: world.color,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      world.emoji,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(world.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            )),
                                        const SizedBox(height: 4),
                                        Text(world.subtitle,
                                            style: Theme.of(context)
                                                .textTheme.bodySmall),
                                        const SizedBox(height: 8),
                                        Text(
                                          done.toString() +
                                              ' of ' +
                                              world.lessons.length.toString() +
                                              ' lessons completed',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF667085),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showWorld(BuildContext context, _LearnWorld world) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF4F6FC),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(world.title,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(world.subtitle),
              const SizedBox(height: 14),
              for (final lesson in world.lessons)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: world.color,
                      child: Text(lesson.emoji),
                    ),
                    title: Text(lesson.title),
                    subtitle: Text(
                      _completed.contains(lesson.id)
                          ? 'Completed · Open to practise again'
                          : 'Short lesson · 3 questions',
                    ),
                    trailing: Icon(
                      _completed.contains(lesson.id)
                          ? Icons.check_circle_rounded
                          : Icons.play_circle_outline_rounded,
                      color: _completed.contains(lesson.id)
                          ? const Color(0xFF219653)
                          : null,
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openLesson(context, lesson);
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

class _LearnLessonScreen extends StatefulWidget {
  const _LearnLessonScreen({
    required this.lesson,
    required this.completed,
    required this.onCompleted,
  });

  final _LearnLesson lesson;
  final bool completed;
  final Future<void> Function() onCompleted;

  @override
  State<_LearnLessonScreen> createState() => _LearnLessonScreenState();
}

class _LearnLessonScreenState extends State<_LearnLessonScreen> {
  int _question = 0;
  int? _selected;
  int _correct = 0;
  bool _answered = false;
  bool _saving = false;
  bool _finished = false;

  void _select(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == widget.lesson.questions[_question].answerIndex) {
        _correct++;
      }
    });
  }

  Future<void> _next() async {
    if (_question < widget.lesson.questions.length - 1) {
      setState(() {
        _question++;
        _selected = null;
        _answered = false;
      });
      return;
    }
    setState(() => _saving = true);
    await widget.onCompleted();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌟', style: TextStyle(fontSize: 66)),
                const SizedBox(height: 12),
                Text(
                  _correct == widget.lesson.questions.length
                      ? 'Amazing work!'
                      : 'Lovely learning!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'You answered ' +
                      _correct.toString() +
                      ' of ' +
                      widget.lesson.questions.length.toString() +
                      ' questions correctly.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to learning worlds'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = widget.lesson.questions[_question];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: const Color(0xFFF4F6FC),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (_question + (_answered ? 1 : 0)) /
                  widget.lesson.questions.length,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(widget.lesson.emoji,
                      style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 10),
                  Text('Discover',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(widget.lesson.fact, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(widget.lesson.practice,
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Try it · ' +
                (_question + 1).toString() +
                ' of ' +
                widget.lesson.questions.length.toString(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(question.prompt,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 12),
          for (var index = 0; index < question.options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: _optionColor(question, index),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  key: Key('learn_answer_' + index.toString()),
                  borderRadius: BorderRadius.circular(16),
                  onTap: _answered ? null : () => _select(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    child: Text(
                      question.options[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          if (_answered) ...[
            const SizedBox(height: 4),
            Text(
              _selected == question.answerIndex
                  ? 'That is right! Great noticing.'
                  : 'Good try. The answer is ' +
                      question.options[question.answerIndex] +
                      '.',
              key: const Key('learn_answer_feedback'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton(
              key: const Key('learn_next_button'),
              onPressed: _saving ? null : _next,
              child: _saving
                  ? const CircularProgressIndicator()
                  : Text(_question == widget.lesson.questions.length - 1
                      ? 'Finish lesson'
                      : 'Next question'),
            ),
          ],
        ],
      ),
    );
  }

  Color _optionColor(_LearnQuestion question, int index) {
    if (!_answered) return Colors.white;
    if (index == question.answerIndex) return const Color(0xFFDDF4E7);
    if (index == _selected) return const Color(0xFFFFE3E3);
    return Colors.white;
  }
}

class _LearnProgressCard extends StatelessWidget {
  const _LearnProgressCard({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFFE6A700)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Your learning journey',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
                Text(completed.toString() + '/' + total.toString()),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnWorld {
  const _LearnWorld(
    this.id,
    this.title,
    this.subtitle,
    this.emoji,
    this.color,
    this.lessons,
  );

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<_LearnLesson> lessons;
}

class _LearnLesson {
  const _LearnLesson(
    this.id,
    this.title,
    this.emoji,
    this.fact,
    this.practice,
    this.questions,
  );

  final String id;
  final String title;
  final String emoji;
  final String fact;
  final String practice;
  final List<_LearnQuestion> questions;
}

class _LearnQuestion {
  const _LearnQuestion(this.prompt, this.options, this.answerIndex);

  final String prompt;
  final List<String> options;
  final int answerIndex;
}
