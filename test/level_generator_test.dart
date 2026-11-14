import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/games/levels/content_bank.dart';
import 'package:kidsgames/features/games/levels/game_level.dart';
import 'package:kidsgames/features/games/levels/level_generator.dart';
import 'package:kidsgames/features/games/levels/level_round.dart';

/// Independently re-derives the answer of every generated round.
void verifyRound(String id, LevelRound round, String where) {
  final reason = '$id $where: ${round.prompt}';
  expect(round.prompt, isNotEmpty, reason: reason);
  expect(round.explanation, isNotEmpty, reason: reason);
  expect(round.options.length, greaterThanOrEqualTo(3), reason: reason);
  if (round.interaction != RoundInteraction.spotInRow) {
    expect(
      round.options.map((o) => o.identity).toSet(),
      hasLength(round.options.length),
      reason: '$reason has duplicate options',
    );
  }

  if (round.interaction == RoundInteraction.order) {
    final values = round.options.map((o) => int.parse(o.value)).toList();
    final tapped = [for (final i in round.orderSolution) values[i]];
    expect(
      round.orderSolution.toSet(),
      hasLength(values.length),
      reason: reason,
    );
    final sorted = [...values]..sort();
    expect(
      tapped,
      round.prompt.contains('biggest to smallest')
          ? sorted.reversed.toList()
          : sorted,
      reason: reason,
    );
    return;
  }

  expect(
    round.correctIndex,
    inInclusiveRange(0, round.options.length - 1),
    reason: reason,
  );
  final correct = round.correctOption;
  final others = [
    for (var i = 0; i < round.options.length; i++)
      if (i != round.correctIndex) round.options[i],
  ];
  if (round.interaction != RoundInteraction.spotInRow) {
    expect(
      round.options.map((o) => o.accessibleLabel).toSet(),
      hasLength(round.options.length),
      reason: '$reason has duplicate accessible labels',
    );
  }

  switch (id) {
    case 'missing_numbers':
      final gap = round.cue.indexWhere((t) => t.kind == TokenKind.gap);
      final values = [
        for (final t in round.cue)
          t.kind == TokenKind.gap ? null : int.parse(t.value),
      ];
      int? step;
      for (var i = 0; i + 1 < values.length; i++) {
        if (values[i] != null && values[i + 1] != null) {
          step = values[i + 1]! - values[i]!;
          break;
        }
      }
      final anchor = values.indexWhere((v) => v != null);
      final expected = values[anchor]! + (gap - anchor) * step!;
      expect(int.parse(correct.value), expected, reason: reason);
      expect(expected, greaterThanOrEqualTo(0), reason: reason);
      for (final o in others) {
        expect(int.parse(o.value), isNot(expected), reason: reason);
      }
    case 'what_comes_next':
    case 'missing_shapes':
      final ids = [
        for (final t in round.cue) t.kind == TokenKind.gap ? null : t.identity,
      ];
      final gap = ids.indexOf(null);
      // Shortest period consistent with every visible item.
      int? period;
      for (var p = 1; p < ids.length; p++) {
        var ok = true;
        for (var i = 0; i < ids.length && ok; i++) {
          for (var j = i + p; j < ids.length; j += p) {
            if (ids[i] != null && ids[j] != null && ids[i] != ids[j]) {
              ok = false;
              break;
            }
          }
        }
        if (ok) {
          period = p;
          break;
        }
      }
      expect(period, isNotNull, reason: reason);
      final witness = [
        for (var i = gap % period!; i < ids.length + period; i += period)
          if (i < ids.length && ids[i] != null) ids[i],
      ];
      if (id == 'what_comes_next') {
        // The gap is after the visible items; extend the pattern.
        expect(gap, ids.length - 1, reason: reason);
      }
      expect(witness, isNotEmpty, reason: '$reason gap is undetermined');
      expect(correct.identity, witness.first, reason: reason);
    case 'number_sequencing':
      fail('ordering handled above');
    case 'big_small':
      if (round.prompt.startsWith('Which number')) {
        final values = round.options.map((o) => int.parse(o.value)).toList();
        final want = round.prompt.contains('biggest')
            ? values.reduce((a, b) => a > b ? a : b)
            : values.reduce((a, b) => a < b ? a : b);
        expect(int.parse(correct.value), want, reason: reason);
      } else if (round.prompt.contains('real life')) {
        int rank(GameToken t) =>
            kSizedThings.firstWhere((s) => s.$1 == t.value).$3;
        for (final o in others) {
          expect(
            round.prompt.contains('biggest')
                ? rank(correct) > rank(o)
                : rank(correct) < rank(o),
            isTrue,
            reason: reason,
          );
        }
      } else {
        for (final o in others) {
          expect(
            round.prompt.contains('biggest')
                ? correct.scale > o.scale
                : correct.scale < o.scale,
            isTrue,
            reason: reason,
          );
        }
      }
    case 'odd_one_out':
      if (round.prompt.contains('number')) {
        final parity = int.parse(correct.value).isEven;
        for (final o in others) {
          expect(int.parse(o.value).isEven, !parity, reason: reason);
        }
      } else {
        Set<String> cats(GameToken t) => {
          for (final entry in kCategories.entries)
            if (entry.value.any((item) => item.$1 == t.value)) entry.key,
        };
        final shared = others.map(cats).reduce((a, b) => a.intersection(b));
        expect(shared, isNotEmpty, reason: reason);
        expect(cats(correct).intersection(shared), isEmpty, reason: reason);
      }
    case 'color_matching':
      String colorOf(GameToken t) => t.kind == TokenKind.colorSwatch
          ? kColorValues.entries.firstWhere((e) => e.value == t.colorValue).key
          : kColoredThings.firstWhere((c) => c.emoji == t.value).color;
      if (round.prompt.startsWith('Mix')) {
        final mix = kColorMixes.firstWhere(
          (m) => round.prompt.startsWith('Mix ${m.$1} and ${m.$2} '),
        );
        expect(colorOf(correct), mix.$3, reason: reason);
      } else if (round.prompt.contains('NOT')) {
        final target = colorOf(round.cue.single);
        expect(colorOf(correct), isNot(target), reason: reason);
        for (final o in others) {
          expect(colorOf(o), target, reason: reason);
        }
      } else if (round.prompt.startsWith('What colour')) {
        expect(colorOf(correct), colorOf(round.cue.single), reason: reason);
      } else {
        final target = colorOf(round.cue.single);
        expect(colorOf(correct), target, reason: reason);
        for (final o in others) {
          expect(colorOf(o), isNot(target), reason: reason);
        }
      }
      if (round.cue.isNotEmpty && !round.prompt.startsWith('Mix')) {
        for (final o in others) {
          expect(colorOf(o), isNot(colorOf(correct)), reason: reason);
        }
      }
    case 'animal_recognition':
      Animal of(GameToken t) => kAnimals.firstWhere((a) => a.emoji == t.value);
      if (round.prompt.startsWith('Who says')) {
        final sound = of(correct).sound!;
        expect(round.prompt, contains(sound), reason: reason);
        for (final o in others) {
          expect(of(o).sound, isNot(sound), reason: reason);
        }
      } else if (round.prompt.startsWith('Which animal lives')) {
        final home = kHomes.entries
            .firstWhere((e) => round.prompt.contains('the ${e.value.$2}?'))
            .key;
        expect(of(correct).homes, contains(home), reason: reason);
        for (final o in others) {
          expect(of(o).homes, isNot(contains(home)), reason: reason);
        }
      } else if (round.prompt.startsWith('Find the')) {
        expect(
          round.prompt,
          contains(of(correct).name.toLowerCase()),
          reason: reason,
        );
      } else {
        final trait = kTraitQuestions.entries
            .firstWhere((e) => e.value == round.prompt)
            .key;
        expect(of(correct).traits, contains(trait), reason: reason);
        for (final o in others) {
          expect(of(o).traits, isNot(contains(trait)), reason: reason);
        }
      }
    case 'alphabet_matching':
      final p = round.prompt;
      if (p.startsWith('Find the letter')) {
        expect(correct.value, round.cue.single.value, reason: reason);
      } else if (p.startsWith('Find the small')) {
        expect(
          correct.value,
          round.cue.single.value.toLowerCase(),
          reason: reason,
        );
      } else if (p.startsWith('Which letter does')) {
        final word = kPictureWords.firstWhere(
          (w) => w.$1 == round.cue[0].value,
        );
        expect(correct.value, word.$2[0], reason: reason);
      } else if (p.startsWith('Which picture')) {
        final letter = round.cue.single.value;
        String wordOf(GameToken t) =>
            kPictureWords.firstWhere((w) => w.$1 == t.value).$2;
        expect(wordOf(correct)[0], letter, reason: reason);
        for (final o in others) {
          expect(wordOf(o)[0], isNot(letter), reason: reason);
        }
      } else {
        final word = kPictureWords.firstWhere(
          (w) => w.$1 == round.cue[0].value,
        );
        final blanked = round.cue[1].value;
        expect(
          blanked.replaceFirst('_', correct.value),
          word.$2,
          reason: reason,
        );
        for (final o in others) {
          expect(
            blanked.replaceFirst('_', o.value),
            isNot(word.$2),
            reason: reason,
          );
        }
      }
      for (final o in others) {
        expect(o.value, isNot(correct.value), reason: reason);
      }
    case 'shape_matching':
      if (round.prompt.contains('straight sides')) {
        final sides = int.parse(RegExp(r'\d+').firstMatch(round.prompt)![0]!);
        expect(correct.shape!.sides, sides, reason: reason);
        for (final o in others) {
          expect(o.shape!.sides, isNot(sides), reason: reason);
        }
      } else if (round.cue.isEmpty) {
        expect(
          round.prompt,
          contains(correct.shape!.label.toLowerCase()),
          reason: reason,
        );
        for (final o in others) {
          expect(o.shape, isNot(correct.shape), reason: reason);
        }
      } else {
        final target = round.cue.single.shape!;
        expect(correct.shape, target, reason: reason);
        for (final o in others) {
          expect(o.shape, isNot(target), reason: reason);
          expect(
            {o.shape, target},
            isNot(containsAll({ShapeKind.square, ShapeKind.diamond})),
            reason: reason,
          );
        }
      }
    case 'find_differences':
      if (round.referenceRow.isNotEmpty) {
        expect(round.referenceRow, hasLength(round.options.length));
        for (var i = 0; i < round.options.length; i++) {
          final same =
              round.options[i].identity == round.referenceRow[i].identity;
          expect(same, i != round.correctIndex, reason: reason);
        }
      } else {
        final base = others.first.identity;
        expect(others.every((o) => o.identity == base), isTrue, reason: reason);
        expect(correct.identity, isNot(base), reason: reason);
      }
    case 'shadow_matching':
      final cue = round.cue.single;
      expect(correct.value, cue.value, reason: reason);
      expect(cue.silhouette != correct.silhouette, isTrue, reason: reason);
      for (final o in others) {
        expect(o.value, isNot(cue.value), reason: reason);
      }
    case 'complete_picture':
      final pair = kPairs.lastWhere(
        (p) => round.prompt.endsWith('the ${p.$2.toLowerCase()}?'),
      );
      expect(correct.value, pair.$3, reason: reason);
      for (final o in others) {
        expect(o.value, isNot(pair.$3), reason: reason);
      }
    default:
      fail('No verifier for $id');
  }
}

void main() {
  test('difficulty rises smoothly with level and starts higher for older '
      'grades', () {
    for (final grade in kGrades) {
      var previous = 0;
      for (var level = 1; level <= kLevelsPerGame; level++) {
        final tier = GameDifficulty(level: level, grade: grade).tier;
        expect(tier, greaterThanOrEqualTo(previous));
        expect(tier - previous, lessThanOrEqualTo(previous == 0 ? 10 : 1));
        previous = tier;
      }
      expect(previous, 10, reason: 'level 1000 reaches the top tier');
    }
    expect(GameDifficulty(level: 1, grade: 'Nursery').tier, 1);
    expect(GameDifficulty(level: 1, grade: 'Grade 5').tier, 4);
    expect(GameDifficulty(level: 5000).tier, 10);
  });

  test('stars reward accuracy and zero stars means retry', () {
    expect(starsFor(5, 5), 3);
    expect(starsFor(4, 5), 2);
    expect(starsFor(3, 5), 1);
    expect(starsFor(2, 5), 0);
    expect(starsFor(0, 0), 0);
  });

  test('levels are deterministic and differ from one another', () {
    for (final id in kQuestionActivityIds) {
      String signature(int level) => generateLevel(
        id,
        level,
      ).map((r) => '${r.prompt}${r.options.map((o) => o.identity)}').join();
      expect(signature(42), signature(42), reason: id);
      final distinct = {for (var l = 1; l <= 30; l++) signature(l)};
      expect(distinct.length, greaterThan(25), reason: '$id repeats levels');
    }
  });

  for (final id in kQuestionActivityIds) {
    test('$id: all $kLevelsPerGame levels for every grade are valid', () {
      for (final grade in kGrades) {
        for (var level = 1; level <= kLevelsPerGame; level++) {
          final rounds = generateLevel(id, level, grade: grade);
          final difficulty = GameDifficulty(level: level, grade: grade);
          expect(rounds, hasLength(difficulty.roundCount));
          for (var i = 0; i < rounds.length; i++) {
            verifyRound(id, rounds[i], '$grade level $level round $i');
          }
        }
      }
    });
  }

  test('Flame level specs scale up', () {
    final first = countingSpecFor(1);
    final last = countingSpecFor(1000);
    expect(first.decoys, 0);
    expect(first.speed, 0);
    expect(first.askTotal, isFalse);
    expect(last.targets, greaterThan(first.targets));
    expect(last.decoys, greaterThan(0));
    expect(last.askTotal, isTrue);
    expect(jigsawSpecFor(1).columns * jigsawSpecFor(1).rows, 4);
    expect(jigsawSpecFor(1000).columns * jigsawSpecFor(1000).rows, 36);
  });
}
