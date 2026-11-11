import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/features/games/flame_counting_game_screen.dart';

void main() {
  testWidgets('Magic Counting opens the Flame garden game', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: FlameCountingGameScreen(
          sessionRepository: MemoryGameSessionRepository(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Find all five glowing stars'), findsOneWidget);
    expect(find.text('Tap each star in the garden to count it.'), findsOneWidget);
    expect(find.byKey(const Key('flame_count_progress')), findsOneWidget);
  });

  testWidgets('tapping all five Flame stars completes and saves a session',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sessions = MemoryGameSessionRepository();
    await tester.pumpWidget(
      MaterialApp(home: FlameCountingGameScreen(sessionRepository: sessions)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final gameFinder = find.byWidgetPredicate(
      (widget) => widget is GameWidget<CountingGardenGame>,
    );
    expect(gameFinder, findsOneWidget);
    final gameRect = tester.getRect(gameFinder);
    const positions = [
      Offset(0.18, 0.28),
      Offset(0.78, 0.22),
      Offset(0.48, 0.48),
      Offset(0.23, 0.76),
      Offset(0.79, 0.72),
    ];

    for (var index = 0; index < positions.length; index++) {
      final position = positions[index];
      await tester.tapAt(Offset(
        gameRect.left + gameRect.width * position.dx,
        gameRect.top + gameRect.height * position.dy,
      ));
      await tester.pump(const Duration(milliseconds: 40));
      expect(
        find.text('Stars found: ${index + 1} / 5'),
        findsOneWidget,
      );
    }

    await tester.pump();
    expect(find.text('You found every star!'), findsOneWidget);
    expect(find.text('Progress saved on this device.'), findsOneWidget);
    final saved = await sessions.recentSessions();
    expect(saved, hasLength(1));
    expect(saved.single.activityId, 'magic_counting');
    expect(saved.single.score, 5);
    expect(saved.single.totalRounds, 5);
  });
}
