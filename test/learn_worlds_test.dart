import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/learn/learn_worlds_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('learning lesson can be completed and progress is shown', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LearnWorldsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Learning worlds'), findsOneWidget);
    await tester.tap(find.byKey(const Key('learn_world_letters')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The letter A'));
    await tester.pumpAndSettle();

    expect(
      find.text('A is the first letter of the alphabet. Apple begins with A.'),
      findsOneWidget,
    );

    const answers = [0, 1, 1];
    for (var index = 0; index < answers.length; index++) {
      final answer = find.byKey(Key('learn_answer_${answers[index]}'));
      await tester.scrollUntilVisible(answer, 250);
      await tester.tap(answer);
      await tester.pumpAndSettle();

      final next = find.byKey(const Key('learn_next_button'));
      await tester.scrollUntilVisible(next, 250);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
    }

    expect(find.text('Amazing work!'), findsOneWidget);
    await tester.tap(find.text('Back to learning worlds'));
    await tester.pumpAndSettle();
    expect(find.text('1/9'), findsOneWidget);

    await tester.tap(find.byKey(const Key('learn_world_letters')));
    await tester.pumpAndSettle();
    expect(find.text('Completed · Open to practise again'), findsOneWidget);
  });
}
