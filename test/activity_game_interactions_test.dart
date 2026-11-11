import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/features/games/activity.dart';
import 'package:kidsgames/features/games/activity_game_screen.dart';

void main() {
  Future<void> pumpActivity(
    WidgetTester tester,
    String activityId,
  ) async {
    final activity = starterActivities.singleWhere(
      (item) => item.id == activityId,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ActivityGameScreen(
          activity: activity,
          sessionRepository: MemoryGameSessionRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('complete picture accepts a dragged answer', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpActivity(tester, 'complete_picture');

    final target = find.text('Drag the answer here');
    final answer = find.byKey(const Key('answer_0'));
    await tester.ensureVisible(target);
    await tester.ensureVisible(answer);
    await tester.pumpAndSettle();

    final offset = tester.getCenter(target) - tester.getCenter(answer);
    await tester.drag(answer, offset);
    await tester.pumpAndSettle();

    expect(find.text('Amazing! ⭐'), findsOneWidget);
  });

  testWidgets('magic counting requires touching every object first',
      (tester) async {
    await pumpActivity(tester, 'magic_counting');

    expect(find.text('Touch each object once (0/3).'), findsOneWidget);
    for (var index = 0; index < 3; index++) {
      final object = find.byKey(Key('count_object_$index'));
      await tester.ensureVisible(object);
      await tester.tap(object);
      await tester.pump();
    }

    expect(find.text('Great counting! Now choose the total.'), findsOneWidget);
    final correctAnswer = find.byKey(const Key('answer_2'));
    await tester.ensureVisible(correctAnswer);
    await tester.tap(correctAnswer);
    await tester.pumpAndSettle();

    expect(find.text('Amazing! ⭐'), findsOneWidget);
  });

  testWidgets('find differences selects the outlier in the visual row',
      (tester) async {
    await pumpActivity(tester, 'find_differences');

    final outlier = find.byKey(const Key('answer_2'));
    await tester.ensureVisible(outlier);
    await tester.tap(outlier);
    await tester.pumpAndSettle();

    expect(find.text('Amazing! ⭐'), findsOneWidget);
    expect(find.text('The third fruit is a pear; the others are apples.'),
        findsOneWidget);
  });
  testWidgets('missing numbers accepts a dragged number', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpActivity(tester, 'missing_numbers');

    final target = find.text('Drag the missing number here');
    final answer = find.byKey(const Key('answer_0'));
    await tester.ensureVisible(target);
    await tester.ensureVisible(answer);
    await tester.pumpAndSettle();

    await tester.drag(
      answer,
      tester.getCenter(target) - tester.getCenter(answer),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amazing! ⭐'), findsOneWidget);
  });

  testWidgets('pattern continuation accepts a dragged next item',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpActivity(tester, 'what_comes_next');

    final target = find.text('Drag the next pattern item here');
    final answer = find.byKey(const Key('answer_0'));
    await tester.ensureVisible(target);
    await tester.ensureVisible(answer);
    await tester.pumpAndSettle();

    await tester.drag(
      answer,
      tester.getCenter(target) - tester.getCenter(answer),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amazing! ⭐'), findsOneWidget);
  });

}
