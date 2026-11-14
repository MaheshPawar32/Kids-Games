import 'dart:math' as math;

import 'content_bank.dart';
import 'game_level.dart';
import 'level_round.dart';

/// Activities rendered by the shared question engine. Magic Counting and
/// Jigsaw Puzzles are Flame games configured by [CountingLevelSpec] and
/// [JigsawLevelSpec].
const kQuestionActivityIds = <String>{
  'complete_picture',
  'shadow_matching',
  'color_matching',
  'shape_matching',
  'alphabet_matching',
  'animal_recognition',
  'odd_one_out',
  'big_small',
  'missing_numbers',
  'missing_shapes',
  'find_differences',
  'number_sequencing',
  'what_comes_next',
};

/// Generates the rounds for one level of [activityId].
///
/// Output is deterministic for (activity, level, grade): replaying a level
/// shows the same questions, and tests can validate every level.
List<LevelRound> generateLevel(String activityId, int level, {String? grade}) {
  if (!kQuestionActivityIds.contains(activityId)) return const [];
  final difficulty = GameDifficulty(level: level, grade: grade);
  final g = _Gen(
    difficulty,
    math.Random(levelSeed(activityId, level, difficulty.gradeIndex)),
  );
  final builder = _builders[activityId]!;
  final rounds = <LevelRound>[];
  final seen = <String>{};
  var attempts = 0;
  while (rounds.length < difficulty.roundCount) {
    final round = builder(g);
    final signature =
        '${round.prompt}|${round.cue.map((t) => t.identity)}|'
        '${round.options.map((t) => t.identity)}';
    attempts++;
    // Avoid repeating a question inside one level; accept after many tries
    // so very small content pools can never loop forever.
    if (seen.add(signature) || attempts > 60) rounds.add(round);
  }
  return rounds;
}

typedef _Builder = LevelRound Function(_Gen g);

const _builders = <String, _Builder>{
  'complete_picture': _completePicture,
  'shadow_matching': _shadowMatching,
  'color_matching': _colorMatching,
  'shape_matching': _shapeMatching,
  'alphabet_matching': _alphabetMatching,
  'animal_recognition': _animalRecognition,
  'odd_one_out': _oddOneOut,
  'big_small': _bigSmall,
  'missing_numbers': _missingNumbers,
  'missing_shapes': _missingShapes,
  'find_differences': _findDifferences,
  'number_sequencing': _numberSequencing,
  'what_comes_next': _whatComesNext,
};

class _Gen {
  _Gen(this.d, this.r);

  final GameDifficulty d;
  final math.Random r;

  int get tier => d.tier;
  int get n => d.optionCount;

  T pick<T>(List<T> list) => list[r.nextInt(list.length)];

  List<T> sample<T>(Iterable<T> source, int count) {
    final copy = source.toList()..shuffle(r);
    return copy.take(count).toList();
  }

  bool chance(double p) => r.nextDouble() < p;

  int between(int min, int max) => min + r.nextInt(max - min + 1);

  /// Chooses a question mode; newer modes for the tier are favoured.
  T mode<T>(List<(int, T)> unlocks) {
    final open = unlocks.where((entry) => entry.$1 <= tier).toList();
    if (open.length > 1 && chance(0.55)) return open.last.$2;
    return pick(open).$2;
  }

  LevelRound choose({
    required String prompt,
    required List<GameToken> cue,
    required GameToken correct,
    required Iterable<GameToken> distractors,
    required String explanation,
    RoundInteraction interaction = RoundInteraction.choose,
    bool showLabels = true,
    int? optionCount,
  }) {
    final want = (optionCount ?? n) - 1;
    final picked = <GameToken>[];
    final ids = {correct.identity};
    final labels = {correct.accessibleLabel};
    for (final token in distractors.toList()..shuffle(r)) {
      if (picked.length == want) break;
      if (ids.add(token.identity) && labels.add(token.accessibleLabel)) {
        picked.add(token);
      }
    }
    final options = [correct, ...picked]..shuffle(r);
    return LevelRound(
      prompt: prompt,
      cue: cue,
      options: options,
      correctIndex: options.indexOf(correct),
      explanation: explanation,
      interaction: interaction,
      showOptionLabels: showLabels,
    );
  }
}

GameToken _e((String, String) item, {double scale = 1}) =>
    GameToken.emoji(item.$1, item.$2, scale: scale);

String _cap(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

String _article(String noun) =>
    'aeiou'.contains(noun[0].toLowerCase()) ? 'an' : 'a';

// ---------------------------------------------------------------------------
// Complete Picture: things that belong together, then picture analogies.

LevelRound _completePicture(_Gen g) {
  final useAnalogy = g.tier >= 7 || (g.tier >= 5 && g.chance(0.5));
  final pair = g.pick(kPairs);
  final distractors = [
    for (final other in kPairs)
      if (other.$4 != pair.$4) GameToken.emoji(other.$3, other.$4),
  ];
  if (!useAnalogy) {
    return g.choose(
      prompt: 'What completes the picture with the ${pair.$2.toLowerCase()}?',
      cue: [
        GameToken.emoji(pair.$1, pair.$2, scale: 1.3),
        const GameToken.text('+'),
        const GameToken.gap(),
      ],
      correct: GameToken.emoji(pair.$3, pair.$4),
      distractors: distractors,
      explanation: pair.$5,
      interaction: RoundInteraction.drag,
    );
  }
  final example = g.pick([
    for (final other in kPairs)
      if (other != pair) other,
  ]);
  return g.choose(
    prompt:
        '${example.$2} goes with ${example.$4.toLowerCase()}. '
        'What goes with the ${pair.$2.toLowerCase()}?',
    cue: [
      GameToken.emoji(example.$1, example.$2),
      const GameToken.text('→'),
      GameToken.emoji(example.$3, example.$4),
      const GameToken.text('|'),
      GameToken.emoji(pair.$1, pair.$2),
      const GameToken.text('→'),
      const GameToken.gap(),
    ],
    correct: GameToken.emoji(pair.$3, pair.$4),
    distractors: distractors.where((t) => t.label != example.$4),
    explanation: pair.$5,
    interaction: RoundInteraction.drag,
  );
}

// ---------------------------------------------------------------------------
// Shadow Matching: real silhouettes; look-alike shadows at higher tiers.

LevelRound _shadowMatching(_Gen g) {
  final List<(String, String)> pool;
  final (String, String) target;
  if (g.tier >= 7) {
    final family = g.pick(kLookalikeFamilies);
    target = g.pick(family);
    pool = [
      ...family.where((item) => item != target),
      ...g.sample(kDistinctItems.where((item) => item.$1 != target.$1), 6),
    ];
  } else {
    final source = g.tier <= 3
        ? kDistinctItems
        : [...kDistinctItems, for (final a in kAnimals) (a.emoji, a.name)];
    target = g.pick(source);
    pool = source.where((item) => item.$2 != target.$2).toList();
  }
  // Higher tiers keep look-alike distractors first so they are included.
  final ordered = g.tier >= 7 ? pool : (pool.toList()..shuffle(g.r));
  final reverse = g.tier >= 5 && g.chance(0.5);
  if (!reverse) {
    return g.choose(
      prompt: 'Whose shadow is this? Drag the picture onto its shadow.',
      cue: [
        GameToken.emoji(target.$1, target.$2, scale: 1.7, silhouette: true),
      ],
      correct: _e(target),
      distractors: ordered.take(8).map(_e),
      explanation: 'That is the shadow of the ${target.$2.toLowerCase()}.',
      interaction: RoundInteraction.drag,
    );
  }
  return g.choose(
    prompt: 'Find the shadow of the ${target.$2.toLowerCase()}.',
    cue: [GameToken.emoji(target.$1, target.$2, scale: 1.5)],
    correct: GameToken.emoji(
      target.$1,
      'Shadow of ${target.$2}',
      silhouette: true,
    ),
    distractors: ordered
        .take(8)
        .map(
          (item) => GameToken.emoji(
            item.$1,
            'Shadow of ${item.$2}',
            silhouette: true,
          ),
        ),
    explanation: 'The ${target.$2.toLowerCase()} makes that shape.',
    showLabels: false,
  );
}

// ---------------------------------------------------------------------------
// Color Matching: find colours, name colours, NOT-colour, then mixing.

List<String> _colorsFor(int tier) => [
  for (var i = 0; i <= math.min(3, (tier - 1) ~/ 2); i++) ...kColorTiers[i],
];

GameToken _swatch(String color) =>
    GameToken.color(kColorValues[color]!, _cap(color));

LevelRound _colorMatching(_Gen g) {
  final colors = _colorsFor(g.tier);
  final things = kColoredThings
      .where((thing) => colors.contains(thing.color))
      .toList();
  final kind = g.mode<String>([
    (1, 'find'),
    (3, 'name'),
    (5, 'not'),
    (7, 'mix'),
  ]);
  switch (kind) {
    case 'name':
      final thing = g.pick(things);
      return g.choose(
        prompt: 'What colour is the ${thing.name.toLowerCase()}?',
        cue: [GameToken.emoji(thing.emoji, thing.name, scale: 1.5)],
        correct: _swatch(thing.color),
        distractors: colors.where((c) => c != thing.color).map(_swatch),
        explanation: 'The ${thing.name.toLowerCase()} is ${thing.color}.',
      );
    case 'not':
      final groups = <String, List<ColoredThing>>{};
      for (final thing in things) {
        groups.putIfAbsent(thing.color, () => []).add(thing);
      }
      final color = g.pick(
        groups.keys.where((c) => groups[c]!.length >= 2).toList(),
      );
      final same = g.sample(groups[color]!, math.min(g.n - 1, 3));
      final odd = g.pick(things.where((t) => t.color != color).toList());
      return g.choose(
        prompt: 'Which one is NOT ${color.toUpperCase()}?',
        cue: [_swatch(color)],
        correct: GameToken.emoji(odd.emoji, odd.name),
        distractors: same.map((t) => GameToken.emoji(t.emoji, t.name)),
        optionCount: same.length + 1,
        explanation:
            'The ${odd.name.toLowerCase()} is ${odd.color}, '
            'not $color.',
      );
    case 'mix':
      final mix = g.pick(kColorMixes);
      final palette = {...colors, 'grey', mix.$3};
      return g.choose(
        prompt: 'Mix ${mix.$1} and ${mix.$2} paint. What colour do you get?',
        cue: [
          _swatch(mix.$1),
          const GameToken.text('+'),
          _swatch(mix.$2),
          const GameToken.text('='),
          const GameToken.gap(),
        ],
        correct: _swatch(mix.$3),
        distractors: palette
            .where((c) => c != mix.$3 && c != mix.$1 && c != mix.$2)
            .map(_swatch),
        explanation: '${_cap(mix.$1)} and ${mix.$2} make ${mix.$3}.',
        interaction: RoundInteraction.drag,
      );
    default:
      final thing = g.pick(things);
      return g.choose(
        prompt: 'Which one is ${thing.color}? Drag it into the paint pot.',
        cue: [_swatch(thing.color)],
        correct: GameToken.emoji(thing.emoji, thing.name),
        distractors: things
            .where((t) => t.color != thing.color)
            .map((t) => GameToken.emoji(t.emoji, t.name)),
        explanation: 'The ${thing.name.toLowerCase()} is ${thing.color}.',
        interaction: RoundInteraction.drag,
      );
  }
}

// ---------------------------------------------------------------------------
// Shape Matching: same shape, rotated shapes, sides, names.

const _shapeColors = [
  0xFF59B9EF,
  0xFF967CEB,
  0xFFFFA45F,
  0xFFFFC94F,
  0xFF66C99B,
  0xFFF06292,
];

const _shapeColorNames = {
  0xFF59B9EF: 'blue',
  0xFF967CEB: 'purple',
  0xFFFFA45F: 'orange',
  0xFFFFC94F: 'yellow',
  0xFF66C99B: 'green',
  0xFFF06292: 'pink',
};

/// Shape token whose accessible label names colour and direction, so
/// options never rely on colour alone and stay distinct.
GameToken _shape(
  ShapeKind shape,
  int color, {
  double rotation = 0,
  double scale = 1,
}) {
  final turn = (rotation % 1 * 4).round() % 4;
  final direction = shape == ShapeKind.triangle && rotation != 0
      ? const [
          ' pointing up',
          ' pointing right',
          ' pointing down',
          ' pointing left',
        ][turn]
      : rotation != 0
      ? ' (turned)'
      : '';
  return GameToken.shape(
    shape,
    color,
    rotation: rotation,
    scale: scale,
    label:
        '${_cap(_shapeColorNames[color]!)} '
        '${shape.label.toLowerCase()}$direction',
  );
}

List<ShapeKind> _shapesFor(int tier) => tier <= 2
    ? const [
        ShapeKind.circle,
        ShapeKind.square,
        ShapeKind.triangle,
        ShapeKind.star,
        ShapeKind.rectangle,
      ]
    : ShapeKind.values;

/// Square and diamond are the same shape turned; never offer both.
bool _shapeClash(ShapeKind a, ShapeKind b) =>
    {a, b}.containsAll({ShapeKind.square, ShapeKind.diamond});

LevelRound _shapeMatching(_Gen g) {
  final kind = g.mode<String>([
    (1, 'same'),
    (3, 'turned'),
    (6, 'sides'),
    (8, 'name'),
  ]);
  final shapes = _shapesFor(g.tier);
  if (kind == 'sides') {
    final sided = [
      ShapeKind.triangle,
      ShapeKind.square,
      ShapeKind.pentagon,
      ShapeKind.hexagon,
    ];
    final target = g.pick(sided);
    return g.choose(
      prompt: 'Which shape has ${target.sides} straight sides?',
      cue: const [],
      correct: _shape(target, g.pick(_shapeColors)),
      distractors: [ShapeKind.circle, ShapeKind.oval, ShapeKind.heart, ...sided]
          .where((s) => s.sides != target.sides)
          .map((s) => _shape(s, g.pick(_shapeColors))),
      explanation: 'A ${target.label.toLowerCase()} has ${target.sides} sides.',
      showLabels: false,
    );
  }
  final target = g.pick(shapes);
  final colorful = g.tier >= 3;
  final targetColor = g.pick(_shapeColors);
  GameToken option(ShapeKind s) =>
      _shape(s, colorful ? g.pick(_shapeColors) : targetColor);
  final distractors = shapes
      .where((s) => s != target && !_shapeClash(s, target))
      .map(option);
  if (kind == 'name') {
    return g.choose(
      prompt: 'Find the ${target.label.toLowerCase()}.',
      cue: const [],
      correct: option(target),
      distractors: distractors,
      explanation:
          'That is ${_article(target.label)} '
          '${target.label.toLowerCase()}.',
      showLabels: false,
    );
  }
  final turned = kind == 'turned' && target != ShapeKind.circle;
  return g.choose(
    prompt: turned
        ? 'This shape is turned around. Which shape is it?'
        : 'Find the same shape. Drag it onto the outline.',
    cue: [
      _shape(
        target,
        targetColor,
        rotation: turned ? g.pick(const [0.125, 0.25, 0.375, 0.5]) : 0,
        scale: 1.4,
      ),
    ],
    correct: option(target),
    distractors: distractors,
    explanation: 'Both are ${target.label.toLowerCase()}s.',
    interaction: RoundInteraction.drag,
    showLabels: g.tier <= 5,
  );
}

// ---------------------------------------------------------------------------
// Alphabet Matching: letters, upper/lower case, first sounds, missing letters.

const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

GameToken _letter(String letter) =>
    GameToken.text(letter, label: 'Letter $letter', scale: 1.4);

Iterable<GameToken> _letterDistractors(_Gen g, String letter, bool lower) {
  final hard = g.tier >= 2 ? (kLookalikeLetters[letter] ?? '') : '';
  final others = _alphabet.split('').where((l) => l != letter).toList()
    ..shuffle(g.r);
  return [...hard.split(''), ...others]
      .where((l) => l.isNotEmpty && l != letter)
      .map((l) => _letter(lower ? l.toLowerCase() : l));
}

LevelRound _alphabetMatching(_Gen g) {
  final kind = g.mode<String>([
    (1, 'same'),
    (3, 'lower'),
    (5, 'first'),
    (7, 'picture'),
    (9, 'missing'),
  ]);
  // Early levels use the first half of the alphabet, then all letters.
  final span = math.min(26, 10 + g.d.scale(0, 40) + g.tier * 2);
  final letter = _alphabet[g.r.nextInt(span)];
  switch (kind) {
    case 'lower':
      return g.choose(
        prompt: 'Find the small letter that matches $letter.',
        cue: [_letter(letter)],
        correct: _letter(letter.toLowerCase()),
        distractors: _letterDistractors(g, letter, true),
        explanation:
            'Big $letter and small ${letter.toLowerCase()} '
            'are the same letter.',
        interaction: RoundInteraction.drag,
      );
    case 'first':
      final word = g.pick(kPictureWords);
      final first = word.$2[0];
      return g.choose(
        prompt: 'Which letter does ${_cap(word.$2.toLowerCase())} start with?',
        cue: [
          GameToken.emoji(word.$1, _cap(word.$2.toLowerCase()), scale: 1.4),
          GameToken.text(
            '_${word.$2.substring(1)}',
            label: 'blank, then ${word.$2.substring(1)}',
          ),
        ],
        correct: _letter(first),
        distractors: _letterDistractors(g, first, false),
        explanation: '${_cap(word.$2.toLowerCase())} starts with $first.',
        interaction: RoundInteraction.drag,
      );
    case 'picture':
      final word = g.pick(kPictureWords);
      final first = word.$2[0];
      return g.choose(
        prompt: 'Which picture starts with the letter $first?',
        cue: [_letter(first)],
        correct: GameToken.emoji(word.$1, _cap(word.$2.toLowerCase())),
        distractors: kPictureWords
            .where((w) => w.$2[0] != first)
            .map((w) => GameToken.emoji(w.$1, _cap(w.$2.toLowerCase()))),
        explanation: '${_cap(word.$2.toLowerCase())} starts with $first.',
        showLabels: false,
      );
    case 'missing':
      final words = kPictureWords
          .where((w) => RegExp(r'^[A-Z]{3,7}$').hasMatch(w.$2))
          .toList();
      final word = g.pick(words);
      final index = g.between(1, word.$2.length - 2);
      final missing = word.$2[index];
      final blanked =
          '${word.$2.substring(0, index)}_${word.$2.substring(index + 1)}';
      final known = kPictureWords.map((w) => w.$2).toSet();
      return g.choose(
        prompt: 'Which letter is missing?',
        cue: [
          GameToken.emoji(word.$1, _cap(word.$2.toLowerCase()), scale: 1.3),
          GameToken.text(blanked, label: blanked.replaceAll('_', ' blank ')),
        ],
        correct: _letter(missing),
        // Never offer a letter that spells another known word.
        distractors: _letterDistractors(
          g,
          missing,
          false,
        ).where((t) => !known.contains(blanked.replaceFirst('_', t.value))),
        explanation: '${_cap(word.$2.toLowerCase())} is spelled ${word.$2}.',
        interaction: RoundInteraction.drag,
      );
    default:
      return g.choose(
        prompt: 'Find the letter $letter.',
        cue: [_letter(letter)],
        correct: _letter(letter),
        distractors: _letterDistractors(g, letter, false),
        explanation: 'You found the letter $letter.',
        interaction: RoundInteraction.drag,
      );
  }
}

// ---------------------------------------------------------------------------
// Animal Recognition: names, sounds, homes and body facts.

const _askedHomes = ['farm', 'pond', 'hive', 'ocean', 'ice', 'desert'];

/// Animals that would make a trait question ambiguous as distractors.
const _ambiguousForTrait = <String, Set<String>>{
  'flies': {'Hen', 'Rooster'},
  'eight_legs': {'Octopus'},
  'stripes': {'Tiger'},
};

GameToken _animal(Animal a) => GameToken.emoji(a.emoji, a.name);

LevelRound _animalRecognition(_Gen g) {
  final kind = g.mode<String>([
    (1, 'name'),
    (2, 'sound'),
    (5, 'home'),
    (7, 'trait'),
  ]);
  switch (kind) {
    case 'sound':
      final animal = g.pick(kAnimals.where((a) => a.sound != null).toList());
      return g.choose(
        prompt: 'Who says “${animal.sound}”?',
        cue: [GameToken.text('🔊 ${animal.sound}!', label: animal.sound!)],
        correct: _animal(animal),
        distractors: kAnimals
            .where((a) => a.sound != null && a.sound != animal.sound)
            .map(_animal),
        explanation:
            'The ${animal.name.toLowerCase()} says '
            '“${animal.sound}”.',
      );
    case 'home':
      final home = g.pick(_askedHomes);
      final (homeEmoji, homeName) = kHomes[home]!;
      final animal = g.pick(
        kAnimals.where((a) => a.homes.contains(home)).toList(),
      );
      return g.choose(
        prompt: 'Which animal lives in the $homeName?',
        cue: [GameToken.emoji(homeEmoji, _cap(homeName), scale: 1.4)],
        correct: _animal(animal),
        distractors: kAnimals
            .where((a) => a.homes.isNotEmpty && !a.homes.contains(home))
            .map(_animal),
        explanation:
            'The ${animal.name.toLowerCase()} lives in the '
            '$homeName.',
      );
    case 'trait':
      final trait = g.pick(kTraitQuestions.keys.toList());
      final animal = g.pick(
        kAnimals.where((a) => a.traits.contains(trait)).toList(),
      );
      final excluded = _ambiguousForTrait[trait] ?? const <String>{};
      return g.choose(
        prompt: kTraitQuestions[trait]!,
        cue: const [],
        correct: _animal(animal),
        distractors: kAnimals
            .where(
              (a) => !a.traits.contains(trait) && !excluded.contains(a.name),
            )
            .map(_animal),
        explanation: kTraitQuestions[trait]!
            .replaceFirst('Which animal', 'The ${animal.name.toLowerCase()}')
            .replaceFirst('?', '.'),
      );
    default:
      final animal = g.pick(kAnimals);
      return g.choose(
        prompt: 'Find the ${animal.name.toLowerCase()}.',
        cue: const [],
        correct: _animal(animal),
        distractors: kAnimals.where((a) => a != animal).map(_animal),
        explanation: 'That is the ${animal.name.toLowerCase()}.',
        showLabels: false,
      );
  }
}

// ---------------------------------------------------------------------------
// Odd One Out: far categories, close categories, then odd/even numbers.

LevelRound _oddOneOut(_Gen g) {
  if (g.tier >= 8 && g.chance(0.35)) {
    final max = g.d.scale(20, 200);
    final evens = g.chance(0.5);
    final numbers = <int>{};
    while (numbers.length < g.n - 1) {
      final value = g.between(1, max);
      if (value.isEven == evens) numbers.add(value);
    }
    int odd;
    do {
      odd = g.between(1, max);
    } while (odd.isEven == evens);
    return g.choose(
      prompt: 'Which number does not belong?',
      cue: const [],
      correct: GameToken.text('$odd', scale: 1.2),
      distractors: numbers.map((v) => GameToken.text('$v', scale: 1.2)),
      explanation: evens
          ? '$odd is odd; the others are even.'
          : '$odd is even; the others are odd.',
    );
  }
  final (String, String) categories;
  if (g.tier >= 7 && g.chance(0.6)) {
    final close = g.pick(kCloseCategories);
    categories = g.chance(0.5) ? close : (close.$2, close.$1);
  } else {
    final names = kCategories.keys.toList();
    String a, b;
    do {
      a = g.pick(names);
      b = g.pick(names);
    } while (a == b ||
        (g.tier <= 3 &&
            kCloseCategories.any(
              (pair) => {pair.$1, pair.$2}.containsAll({a, b}),
            )));
    categories = (a, b);
  }
  final (groupName, oddName) = categories;
  final group = g.sample(kCategories[groupName]!, g.n - 1);
  final odd = g.pick(kCategories[oddName]!);
  return g.choose(
    prompt: 'Which one does not belong?',
    cue: const [],
    correct: _e(odd),
    distractors: group.map(_e),
    optionCount: group.length + 1,
    explanation: '${odd.$2} does not belong with the $groupName.',
  );
}

// ---------------------------------------------------------------------------
// Big & Small: visual size, real-world size, then comparing numbers.

LevelRound _bigSmall(_Gen g) {
  final kind = g.mode<String>([(1, 'visual'), (3, 'real'), (7, 'number')]);
  final biggest = g.chance(0.5);
  final word = biggest ? 'biggest' : 'smallest';
  switch (kind) {
    case 'real':
      final gap = g.tier <= 5 ? 2 : 1;
      final target = g.pick(kSizedThings);
      final others = kSizedThings.where(
        (t) => biggest ? t.$3 <= target.$3 - gap : t.$3 >= target.$3 + gap,
      );
      if (others.length < g.n - 1) return _bigSmall(g);
      return g.choose(
        prompt: 'Which is the $word in real life?',
        cue: const [],
        correct: GameToken.emoji(target.$1, target.$2),
        distractors: others.map((t) => GameToken.emoji(t.$1, t.$2)),
        explanation: biggest
            ? 'A ${target.$2.toLowerCase()} is bigger than the others.'
            : 'A ${target.$2.toLowerCase()} is smaller than the others.',
      );
    case 'number':
      final max = g.d.scale(50, 999) + g.d.gradeIndex * 50;
      final values = <int>{};
      if (g.tier >= 9 && g.chance(0.5)) {
        // Same digits in a different order: 409, 490, 940 …
        final digits = [g.between(1, 9), g.between(0, 9), g.between(0, 9)];
        for (var i = 0; i < 40 && values.length < g.n; i++) {
          final shuffled = [...digits]..shuffle(g.r);
          if (shuffled.first != 0) {
            values.add(int.parse(shuffled.join()));
          }
        }
      }
      while (values.length < g.n) {
        values.add(g.between(1, max));
      }
      final sorted = values.toList()..sort();
      final answer = biggest ? sorted.last : sorted.first;
      return g.choose(
        prompt: 'Which number is the $word?',
        cue: const [],
        correct: GameToken.text('$answer', scale: 1.2),
        distractors: values
            .where((v) => v != answer)
            .map((v) => GameToken.text('$v', scale: 1.2)),
        optionCount: values.length,
        explanation: biggest
            ? '$answer is the biggest number.'
            : '$answer is the smallest number.',
      );
    default:
      final item = g.pick(kDistinctItems);
      // The size gap narrows as the child improves.
      final step = math.max(0.12, 0.42 - g.tier * 0.06);
      final scales = [for (var i = 0; i < g.n; i++) 0.7 + i * step]
        ..shuffle(g.r);
      final target = biggest
          ? scales.reduce(math.max)
          : scales.reduce(math.min);
      return g.choose(
        prompt: 'Tap the $word ${item.$2.toLowerCase()}.',
        cue: const [],
        correct: GameToken.emoji(item.$1, '$word ${item.$2}', scale: target),
        distractors: scales
            .where((s) => s != target)
            .map(
              (s) => GameToken.emoji(
                item.$1,
                '${s < target ? 'smaller' : 'bigger'} ${item.$2} '
                '${(s * 100).round()}',
                scale: s,
              ),
            ),
        explanation: 'That ${item.$2.toLowerCase()} is the $word.',
        showLabels: false,
      );
  }
}

// ---------------------------------------------------------------------------
// Number sequences shared by Missing Numbers.

({int start, int step, int length}) _sequenceRule(_Gen g) {
  final tier = g.tier;
  final growth = g.d.scale(0, 30);
  int step;
  int start;
  switch (tier) {
    case 1:
      step = 1;
      start = g.between(1, 5);
    case 2:
      step = 1;
      start = g.between(1, 14);
    case 3:
      step = 1;
      start = g.between(5, 40 + growth);
    case 4:
      step = g.pick(const [1, 2]);
      start = g.between(2, 60 + growth) ~/ step * step;
    case 5:
      step = g.pick(const [2, 5, 10]);
      start = g.between(1, 9) * step;
    case 6:
      step = -g.pick(const [1, 2, 5]);
      start = g.between(20, 100);
    case 7:
      step = g.pick(const [3, 4, 5, -3, -10]);
      start = g.between(30, 150 + growth);
    case 8:
      step = g.pick(const [10, 25, 50, 100]);
      start = g.between(1, 9) * step;
    case 9:
      step = g.pick(const [6, 7, 8, 9, 11, 12]);
      start = step * g.between(1, 6);
    default:
      step = g.pick(const [-25, -12, 15, 20, 75, -9]);
      start = g.between(100, 600);
  }
  final length = tier <= 2
      ? 4
      : tier <= 6
      ? 5
      : 6;
  // Keep descending sequences positive.
  if (step < 0) start = math.max(start, -step * (length + 1));
  return (start: start, step: step, length: length);
}

LevelRound _missingNumbers(_Gen g) {
  final rule = _sequenceRule(g);
  final values = [
    for (var i = 0; i < rule.length; i++) rule.start + i * rule.step,
  ];
  final gapIndex = g.tier <= 1 ? rule.length - 1 : g.r.nextInt(rule.length);
  final answer = values[gapIndex];
  final step = rule.step.abs();
  final distractors = <int>{
    answer + 1,
    answer - 1,
    answer + step + 1,
    answer + 10,
    answer - 10,
    if (step > 1) answer + step ~/ 2,
    answer + 2,
  }..removeWhere((v) => v < 0 || v == answer);
  return g.choose(
    prompt: 'Which number is missing? Drag it into the gap.',
    cue: [
      for (var i = 0; i < values.length; i++)
        i == gapIndex ? const GameToken.gap() : GameToken.text('${values[i]}'),
    ],
    correct: GameToken.text('$answer', scale: 1.2),
    distractors: distractors.map((v) => GameToken.text('$v', scale: 1.2)),
    explanation: rule.step > 0
        ? 'Count up by $step: the missing number is $answer.'
        : 'Count down by $step: the missing number is $answer.',
    interaction: RoundInteraction.drag,
  );
}

// ---------------------------------------------------------------------------
// Number Sequencing: tap numbers into order (ascending, then descending).

LevelRound _numberSequencing(_Gen g) {
  final count = g.tier <= 1
      ? 3
      : g.tier <= 3
      ? 4
      : g.tier <= 6
      ? 5
      : 6;
  final values = <int>{};
  if (g.tier <= 2) {
    final start = g.between(1, g.tier == 1 ? 6 : 15);
    values.addAll([for (var i = 0; i < count; i++) start + i]);
  } else {
    final max = g.d.scale(20, 900) + g.d.gradeIndex * 40;
    while (values.length < count) {
      values.add(g.between(1, max));
    }
  }
  final descending = g.tier >= 5 && g.chance(0.4);
  final options = values.map((v) => GameToken.text('$v', scale: 1.2)).toList()
    ..shuffle(g.r);
  final ordered = [...values]..sort();
  if (descending) {
    ordered.setAll(0, ordered.reversed.toList());
  }
  return LevelRound(
    prompt: descending
        ? 'Tap the numbers from biggest to smallest.'
        : 'Tap the numbers from smallest to biggest.',
    cue: const [],
    options: options,
    correctIndex: -1,
    orderSolution: [
      for (final value in ordered)
        options.indexWhere((t) => t.value == '$value'),
    ],
    explanation: 'In order: ${ordered.join(', ')}.',
    interaction: RoundInteraction.order,
  );
}

// ---------------------------------------------------------------------------
// Repeating patterns (What Comes Next) and shape patterns (Missing Shapes).

List<int> _patternUnit(_Gen g) {
  final units = <(int, List<int>)>[
    (1, [0, 1]),
    (2, [0, 0, 1]),
    (3, [0, 1, 2]),
    (3, [0, 1, 1]),
    (4, [0, 0, 1, 1]),
    (5, [0, 1, 2, 3]),
    (5, [0, 0, 1, 2]),
    (6, [0, 1, 2, 1]),
    (7, [0, 1, 1, 2, 2]),
    (8, [0, 1, 2, 3, 4]),
    (9, [0, 0, 1, 2, 2]),
  ];
  return g.mode(units);
}

LevelRound _whatComesNext(_Gen g) {
  final unit = _patternUnit(g);
  final kinds = unit.reduce(math.max) + 1;
  final items = g.sample(kPatternItems, kinds);
  final reps = unit.length <= 3 ? 3 : 2;
  final sequence = [
    for (var i = 0; i < unit.length * reps; i++) unit[i % unit.length],
  ];
  // Higher tiers stop part-way through a repeat.
  final shown = g.tier >= 4
      ? sequence.length - g.r.nextInt(unit.length)
      : sequence.length;
  final visible = sequence.take(shown).toList();
  final next = items[unit[shown % unit.length]];
  return g.choose(
    prompt: 'What comes next? Drag it into the gap.',
    cue: [...visible.map((i) => _e(items[i])), const GameToken.gap()],
    correct: _e(next),
    distractors: [
      ...items.where((i) => i != next).map(_e),
      ...kPatternItems.where((i) => !items.contains(i)).map(_e),
    ],
    explanation:
        'The pattern ${unit.map((i) => items[i].$2.toLowerCase()).join(', ')} '
        'repeats, so ${next.$2.toLowerCase()} comes next.',
    interaction: RoundInteraction.drag,
  );
}

LevelRound _missingShapes(_Gen g) {
  final shapeUnit = _patternUnit(g);
  final shapeKinds = g.sample(
    _shapesFor(g.tier).where((s) => s != ShapeKind.diamond),
    shapeUnit.reduce(math.max) + 1,
  );
  // Tier 5+: colour follows its own cycle; tier 7+: triangles also rotate.
  final colorCycle = g.tier >= 5 ? g.between(2, 3) : 1;
  final colors = g.sample(_shapeColors, colorCycle);
  final rotate = g.tier >= 7 && g.chance(0.5);
  var colorCount = colorCycle;
  int period() => _lcm(rotate ? 4 : shapeUnit.length, colorCount);
  // Keep rows short enough to read: drop the colour cycle if needed.
  if (period() > 6) {
    colorCount = 1;
  }
  final length = math.min(10, math.max(g.tier <= 4 ? 6 : 8, period() + 3));
  GameToken at(int i) {
    final shape = rotate
        ? ShapeKind.triangle
        : shapeKinds[shapeUnit[i % shapeUnit.length]];
    return _shape(
      shape,
      colors[i % colorCount],
      rotation: rotate ? (i % 4) * 0.25 : 0,
    );
  }

  // The gap must sit where the full pattern repeats elsewhere in the row,
  // otherwise the answer would not be determined by what is visible.
  final p = period();
  final solvable = [
    for (var j = 1; j < length; j++)
      if (j - p >= 0 || j + p < length) j,
  ];
  final gapIndex = g.tier <= 1 ? length - 1 : g.pick(solvable);
  final answer = at(gapIndex);
  final distractors = <GameToken>[
    for (final color in _shapeColors)
      _shape(answer.shape!, color, rotation: answer.rotation),
    if (!rotate)
      for (final shape in shapeKinds)
        _shape(shape, answer.colorValue!, rotation: answer.rotation),
    if (rotate)
      for (final turn in const [0.0, 0.25, 0.5, 0.75])
        _shape(ShapeKind.triangle, answer.colorValue!, rotation: turn),
  ];
  return g.choose(
    prompt: 'Which shape is missing from the pattern?',
    cue: [
      for (var i = 0; i < length; i++)
        i == gapIndex ? const GameToken.gap() : at(i),
    ],
    correct: answer,
    distractors: distractors,
    explanation: rotate
        ? 'Each triangle turns a quarter turn.'
        : 'Look at what repeats: the missing shape keeps the pattern going.',
    interaction: RoundInteraction.drag,
    showLabels: false,
  );
}

// ---------------------------------------------------------------------------
// Find Differences: odd item in a row, then compare two pictures.

LevelRound _findDifferences(_Gen g) {
  final count = g.tier <= 2
      ? 4
      : g.tier <= 5
      ? 5
      : g.tier <= 8
      ? 6
      : 8;
  (String, String) swapFor((String, String) item) {
    if (g.tier >= 7) {
      final family = kLookalikeFamilies
          .where((f) => f.contains(item))
          .firstOrNull;
      if (family != null) {
        return g.pick(family.where((i) => i != item).toList());
      }
    }
    return g.pick(kDistinctItems.where((i) => i != item).toList());
  }

  final compare = g.tier >= 4 && g.chance(0.6);
  final changed = g.r.nextInt(count);
  if (!compare) {
    final base = g.tier >= 7
        ? g.pick(g.pick(kLookalikeFamilies))
        : g.pick(kDistinctItems);
    final odd = swapFor(base);
    final options = [
      for (var i = 0; i < count; i++)
        GameToken.emoji(
          i == changed ? odd.$1 : base.$1,
          i == changed ? odd.$2 : base.$2,
        ),
    ];
    return LevelRound(
      prompt: 'Tap the one that is different.',
      cue: const [],
      options: options,
      correctIndex: changed,
      explanation:
          'That one is ${_article(odd.$2)} ${odd.$2.toLowerCase()}; '
          'the others are ${base.$2.toLowerCase()}s.',
      interaction: RoundInteraction.spotInRow,
    );
  }
  final source = g.tier >= 7
      ? [for (final family in kLookalikeFamilies) family.first]
      : kDistinctItems;
  final picture = g.sample(source, count);
  final replacement = swapFor(picture[changed]);
  final bottom = [
    for (var i = 0; i < count; i++) _e(i == changed ? replacement : picture[i]),
  ];
  return LevelRound(
    prompt: 'Look at both pictures. Tap what changed in the bottom one.',
    cue: const [],
    referenceRow: picture.map(_e).toList(),
    options: bottom,
    correctIndex: changed,
    explanation:
        'The ${picture[changed].$2.toLowerCase()} changed into '
        '${_article(replacement.$2)} ${replacement.$2.toLowerCase()}.',
    interaction: RoundInteraction.spotInRow,
  );
}

// ---------------------------------------------------------------------------
// Flame game level specs.

/// Magic Counting (Flame): tap every target; decoys and motion grow.
class CountingLevelSpec {
  const CountingLevelSpec({
    required this.targets,
    required this.decoys,
    required this.speed,
    required this.askTotal,
    required this.gardens,
  });

  /// Targets per garden.
  final int targets;

  /// Objects that must not be tapped.
  final int decoys;

  /// Drift speed in logical pixels per second.
  final double speed;

  /// Hide the live counter and ask for the total afterwards.
  final bool askTotal;

  /// Gardens (rounds) in the level.
  final int gardens;
}

CountingLevelSpec countingSpecFor(int level, {String? grade}) {
  final d = GameDifficulty(level: level, grade: grade);
  final r = math.Random(levelSeed('magic_counting', level, d.gradeIndex));
  final maxTargets = math.min(20, 3 + d.tier + d.scale(0, 6));
  return CountingLevelSpec(
    targets: math.max(3, maxTargets - r.nextInt(3)),
    decoys: d.tier <= 2 ? 0 : math.min(10, (d.tier - 2) + d.scale(0, 3)),
    speed: d.tier <= 3 ? 0 : 12.0 + d.tier * 6 + d.scale(0, 20),
    askTotal: d.tier >= 4,
    gardens: d.tier <= 3 ? 3 : 4,
  );
}

/// Jigsaw Puzzles (Flame): grid grows from 2×2 to 6×6.
class JigsawLevelSpec {
  const JigsawLevelSpec({
    required this.columns,
    required this.rows,
    required this.sceneSeed,
    required this.showGuide,
  });

  final int columns;
  final int rows;
  final int sceneSeed;

  /// Faint picture on the board; removed at higher tiers.
  final bool showGuide;

  int get pieces => columns * rows;

  /// Stars from moves: a perfect solve uses one move per piece.
  int starsForMoves(int moves) {
    if (moves <= pieces + pieces ~/ 4) return 3;
    if (moves <= pieces * 2) return 2;
    return 1;
  }
}

JigsawLevelSpec jigsawSpecFor(int level, {String? grade}) {
  final d = GameDifficulty(level: level, grade: grade);
  const grids = [
    (2, 2),
    (3, 2),
    (3, 3),
    (4, 3),
    (4, 4),
    (5, 4),
    (5, 5),
    (6, 5),
    (6, 6),
    (6, 6),
  ];
  final grid = grids[d.tier - 1];
  return JigsawLevelSpec(
    columns: grid.$1,
    rows: grid.$2,
    sceneSeed: levelSeed('jigsaw_puzzles', level, d.gradeIndex),
    showGuide: d.tier <= 4,
  );
}

int _lcm(int a, int b) {
  int gcd(int x, int y) => y == 0 ? x : gcd(y, x % y);
  return a * b ~/ gcd(a, b);
}
