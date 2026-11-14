import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/data/repositories/level_progress_repository.dart';
import 'package:kidsgames/features/games/jigsaw_puzzles/jigsaw_puzzles_game_screen.dart';
import 'package:kidsgames/features/games/levels/level_generator.dart';

Finder get _gameFinder =>
    find.byWidgetPredicate((widget) => widget is GameWidget<JigsawGame>);

JigsawGame _game(WidgetTester tester) =>
    tester.widget<GameWidget<JigsawGame>>(_gameFinder).game!;

void main() {
  Future<
    ({
      MemoryGameSessionRepository sessions,
      MemoryLevelProgressRepository progress,
    })
  >
  pumpLevel(WidgetTester tester, int level) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sessions = MemoryGameSessionRepository();
    final progress = MemoryLevelProgressRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: JigsawPuzzlesGameScreen(
          level: level,
          sessionRepository: sessions,
          progressRepository: progress,
          onNextLevel: (_) {},
        ),
      ),
    );
    // The picture is rendered off-screen with real async image encoding.
    for (var i = 0; i < 20 && _game(tester).pieces.isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pump(const Duration(milliseconds: 20));
    return (sessions: sessions, progress: progress);
  }

  Offset centerOf(WidgetTester tester, Offset gamePoint) =>
      tester.getTopLeft(_gameFinder) + gamePoint;

  testWidgets('level grids grow from 2×2 to 6×6', (tester) async {
    expect(jigsawSpecFor(1).pieces, 4);
    expect(jigsawSpecFor(1).showGuide, isTrue);
    expect(jigsawSpecFor(1000).pieces, 36);
    expect(jigsawSpecFor(1000).showGuide, isFalse);
  });

  testWidgets('dragging every piece home snaps it, completes the picture '
      'and saves three stars', (tester) async {
    final setup = await pumpLevel(tester, 1);
    final game = _game(tester);
    expect(game.pieces, hasLength(4));

    for (final piece in [...game.pieces]) {
      final half = piece.size.toOffset() / 2;
      final from = centerOf(tester, piece.position.toOffset() + half);
      final to = centerOf(tester, piece.home.toOffset() + half);
      await tester.timedDragFrom(
        from,
        to - from,
        const Duration(milliseconds: 300),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        piece.placed,
        isTrue,
        reason: 'piece ${piece.row},${piece.column}',
      );
    }
    expect(find.text('4/4 · 4 moves'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Level 1 complete!'), findsOneWidget);
    expect(find.text('Solved in 4 moves (4 is perfect).'), findsOneWidget);
    final progress = await setup.progress.load('jigsaw_puzzles');
    expect(progress.starsFor(1), 3);
    expect(progress.unlockedLevel, 2);
    final sessions = await setup.sessions.recentSessions();
    expect(sessions.single.level, 1);
  });

  testWidgets('a piece dropped in the wrong place stays loose and counts '
      'a move', (tester) async {
    await pumpLevel(tester, 1);
    final game = _game(tester);
    final piece = game.pieces.first;
    final wrong = game.pieces.last;
    final half = piece.size.toOffset() / 2;
    final from = centerOf(tester, piece.position.toOffset() + half);
    final to = centerOf(tester, wrong.home.toOffset() + half);
    await tester.timedDragFrom(
      from,
      to - from,
      const Duration(milliseconds: 300),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(piece.placed, isFalse);
    expect(find.text('0/4 · 1 moves'), findsOneWidget);
  });

  testWidgets('tap a piece, then tap its spot, places it (no dragging)', (
    tester,
  ) async {
    await pumpLevel(tester, 1);
    final game = _game(tester);
    final piece = game.pieces.first;
    final half = piece.size.toOffset() / 2;
    await tester.tapAt(centerOf(tester, piece.position.toOffset() + half));
    await tester.pump(const Duration(milliseconds: 50));
    expect(piece.selected, isTrue);
    final cellCenter =
        game.boardOrigin.toOffset() +
        Offset((piece.column + 0.5) * game.cell, (piece.row + 0.5) * game.cell);
    await tester.tapAt(centerOf(tester, cellCenter));
    await tester.pump(const Duration(milliseconds: 200));
    expect(piece.placed, isTrue);
    expect(find.text('1/4 · 1 moves'), findsOneWidget);
  });
}
