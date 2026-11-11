import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/games/activity.dart';
import 'package:kidsgames/features/games/activity_rounds.dart';

void main() {
  const dedicatedActivityIds = {
    'shape_matching',
    'odd_one_out',
    'jigsaw_puzzles',
  };

  final choiceActivities = starterActivities
      .where((activity) => !dedicatedActivityIds.contains(activity.id))
      .toList();

  test('every choice activity provides five complete offline rounds', () {
    expect(choiceActivities, hasLength(12));

    for (final activity in choiceActivities) {
      final rounds = activityRoundsFor(activity.id);

      expect(
        rounds,
        hasLength(5),
        reason: '${activity.id} must contain exactly five playable rounds.',
      );

      for (var index = 0; index < rounds.length; index++) {
        final round = rounds[index];
        expect(round.prompt, isNotEmpty, reason: '${activity.id} round $index');
        expect(round.cue, isNotEmpty, reason: '${activity.id} round $index');
        expect(round.explanation, isNotEmpty,
            reason: '${activity.id} round $index');
        expect(round.options, hasLength(4),
            reason: '${activity.id} round $index');
        expect(round.correctIndex, inInclusiveRange(0, 3),
            reason: '${activity.id} round $index');
        expect(
          round.options.map((option) => option.label).toSet(),
          hasLength(4),
          reason: '${activity.id} round $index must have four distinct answers.',
        );
        for (final option in round.options) {
          expect(option.emoji, isNotEmpty);
          expect(option.label, isNotEmpty);
        }
      }
    }
  });

  test('dedicated drag and match activities are not routed to the quiz engine', () {
    for (final id in dedicatedActivityIds) {
      expect(activityRoundsFor(id), isEmpty, reason: '$id has its own game screen.');
    }
  });

  test('complete picture preserves the established answer progression', () {
    final rounds = activityRoundsFor('complete_picture');

    expect(rounds.map((round) => round.correctIndex), [0, 2, 0, 2, 0]);
    expect(
      rounds.map((round) => round.prompt).toSet(),
      {'Choose the piece that completes the picture.'},
    );
  });

  test('learning activities have distinct question content', () {
    final prompts = {
      for (final activity in choiceActivities)
        activity.id: activityRoundsFor(activity.id).first.prompt,
    };

    expect(prompts['color_matching'], contains('color'));
    expect(prompts['alphabet_matching'], contains('letter'));
    expect(prompts['magic_counting'], contains('many'));
    expect(prompts['number_sequencing'], contains('sequence'));
    expect(prompts['find_differences'], contains('different'));
  });
  test('counting rounds display exactly the number in the answer key', () {
    for (final round in activityRoundsFor('magic_counting')) {
      final symbols = round.cue.split(RegExp(r'\\s+'));
      final object = symbols.first;
      final displayedCount = symbols.where((symbol) => symbol == object).length;
      final answer = int.parse(round.options[round.correctIndex].label);
      expect(displayedCount, answer, reason: round.prompt);
    }
  });

  test('find-differences rounds point to the only outlier position', () {
    for (final round in activityRoundsFor('find_differences')) {
      final symbols = round.cue.split(RegExp(r'\\s+'));
      expect(symbols, hasLength(round.options.length));
      final chosen = symbols[round.correctIndex];
      expect(symbols.where((symbol) => symbol == chosen), hasLength(1));
    }
  });

}
