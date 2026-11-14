import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/data/repositories/level_progress_repository.dart';
import 'package:kidsgames/features/games/flame_counting_game_screen.dart';
import 'package:kidsgames/features/games/levels/level_generator.dart';

Finder get _gameFinder => find.byWidgetPredicate(
  (widget) => widget is GameWidget<CountingGardenGame>,
);

CountingGardenGame _game(WidgetTester tester) =>
    tester.widget<GameWidget<CountingGardenGame>>(_gameFinder).game!;

Future<void> _tapComponent(WidgetTester tester, Offset gamePosition) async {
  final origin = tester.getTopLeft(_gameFinder);
  await tester.tapAt(origin + gamePosition);
  await tester.pump(const Duration(milliseconds: 20));
}

void main() {
  setUp(() {});

  Future<
    ({
      MemoryGameSessionRepository sessions,
      MemoryLevelProgressRepository progress,
      List<int> next,
    })
  >
  pumpLevel(WidgetTester tester, int level, {String? grade}) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sessions = MemoryGameSessionRepository();
    final progress = MemoryLevelProgressRepository();
    final next = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: FlameCountingGameScreen(
          level: level,
          grade: grade,
          sessionRepository: sessions,
          progressRepository: progress,
          onNextLevel: next.add,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    return (sessions: sessions, progress: progress, next: next);
  }

  testWidgets('level 1 is three still gardens; tapping every star '
      'completes, saves and unlocks level 2', (tester) async {
    final spec = countingSpecFor(1);
    expect(spec.decoys, 0);
    expect(spec.speed, 0);
    final setup = await pumpLevel(tester, 1);
    expect(find.text('Touch every glowing star to count it'), findsOneWidget);

    for (var garden = 0; garden < spec.gardens; garden++) {
      final game = _game(tester);
      expect(game.targets, hasLength(spec.targets));
      expect(game.decoys, isEmpty);
      for (var i = 0; i < game.targets.length; i++) {
        await _tapComponent(tester, game.targets[i].position.toOffset());
        expect(
          find.text('Stars found: ${i + 1} / ${spec.targets}'),
          findsOneWidget,
        );
      }
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Wonderful counting!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('next_garden_button')));
      // Flame mounts loaded components on the following game tick.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Level 1 complete!'), findsOneWidget);
    expect(find.text('Progress saved on this device.'), findsOneWidget);
    final saved = await setup.sessions.recentSessions();
    expect(saved.single.activityId, 'magic_counting');
    expect(saved.single.level, 1);
    expect(saved.single.score, spec.gardens);
    final progress = await setup.progress.load('magic_counting');
    expect(progress.starsFor(1), 3);
    expect(progress.unlockedLevel, 2);

    await tester.tap(find.byKey(const Key('next_level_button')));
    expect(setup.next, [2]);
  });

  testWidgets('high levels add moving decoys and ask for the total; '
      'touching a decoy loses the garden', (tester) async {
    final spec = countingSpecFor(900);
    expect(spec.decoys, greaterThan(0));
    expect(spec.speed, greaterThan(0));
    expect(spec.askTotal, isTrue);
    await pumpLevel(tester, 900);
    expect(find.text('Stars found: ?'), findsOneWidget);

    final game = _game(tester);
    await _tapComponent(tester, game.decoys.first.position.toOffset());
    for (final target in game.targets) {
      await _tapComponent(tester, target.position.toOffset());
    }
    expect(game.collected, spec.targets);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('How many stars did you count?'), findsOneWidget);
    await tester.tap(find.byKey(Key('total_${spec.targets}')));
    await tester.pump();
    expect(find.text('Good try!'), findsOneWidget);
    expect(find.textContaining('you touched 1 decoy'), findsOneWidget);
  });

  testWidgets('pausing freezes the garden and resume continues', (
    tester,
  ) async {
    await pumpLevel(tester, 1);
    await tester.tap(find.byTooltip('Pause game'));
    await tester.pump();
    expect(find.text('Take a little break'), findsOneWidget);
    expect(_game(tester).paused, isTrue);
    await tester.tap(find.byKey(const Key('resume_button')));
    await tester.pump();
    expect(_game(tester).paused, isFalse);
  });
}
