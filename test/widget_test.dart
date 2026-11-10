import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/app/kids_games_app.dart';
import 'package:kidsgames/features/onboarding/child_profile.dart';
import 'package:kidsgames/features/onboarding/child_profile_repository.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';

class _FakeChildProfileRepository implements ChildProfileRepository {
  _FakeChildProfileRepository({this.profile});

  ChildProfile? profile;

  @override
  Future<void> clearProfile() async {
    profile = null;
  }

  @override
  Future<ChildProfile?> loadProfile() async => profile;

  @override
  Future<void> saveProfile(ChildProfile value) async {
    profile = value;
  }
}

void main() {
  testWidgets('first launch completes child setup and opens the home screen', (
    tester,
  ) async {
    final repository = _FakeChildProfileRepository();

    await tester.pumpWidget(KidsGamesApp(profileRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to your play world!'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('child_name_field')),
      'Ava',
    );
    await tester.tap(find.byKey(const Key('grade_Grade 1')));
    await tester.pump();

    final startButton = find.byKey(const Key('start_adventure_button'));
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(repository.profile?.name, 'Ava');
    expect(repository.profile?.grade, 'Grade 1');
    expect(find.text('Hello, Ava!'), findsOneWidget);
    expect(find.text('Try a game'), findsOneWidget);
  });

  testWidgets('saved child profile skips onboarding', (tester) async {
    final repository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Leo', grade: 'UKG'),
    );

    await tester.pumpWidget(KidsGamesApp(profileRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Leo!'), findsOneWidget);
    expect(find.text('Welcome to your play world!'), findsNothing);
  });

  testWidgets('bottom navigation switches to the games tab', (tester) async {
    final repository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Mia', grade: 'Grade 2'),
    );

    await tester.pumpWidget(KidsGamesApp(profileRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();

    expect(find.text('Game world'), findsOneWidget);
    expect(find.text('Complete Picture'), findsOneWidget);
  });

  testWidgets('Shape Matching opens and accepts the correct answer', (
    tester,
  ) async {
    final repository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Sam', grade: 'Grade 1'),
    );

    await tester.pumpWidget(KidsGamesApp(profileRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();

    final shapeTile = find.byKey(const Key('activity_shape_matching')).last;
    await tester.ensureVisible(shapeTile);
    await tester.pumpAndSettle();
    await tester.tap(shapeTile);
    await tester.pumpAndSettle();

    expect(find.text('Find the same shape'), findsOneWidget);
    final circleOption = find.byKey(const Key('shape_option_circle'));
    await tester.ensureVisible(circleOption);
    await tester.pumpAndSettle();
    await tester.tap(circleOption);
    await tester.pumpAndSettle();

    expect(find.text('Great matching! You found the circle.'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('catalogue activities open a playable round and show results', (
    tester,
  ) async {
    final repository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Ava', grade: 'Grade 1'),
    );

    await tester.pumpWidget(KidsGamesApp(profileRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();

    final tile = find.byKey(const Key('activity_complete_picture'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.text('Complete Picture'), findsOneWidget);
    expect(find.text('Choose the piece that completes the picture.'), findsOneWidget);

    for (var round = 0; round < 5; round++) {
      await tester.tap(find.byKey(const Key('answer_0')));
      await tester.pumpAndSettle();
      final next = find.text(round == 4 ? 'See my score' : 'Next');
      await tester.ensureVisible(next);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
    }

    expect(find.text('Wonderful work!'), findsOneWidget);
    // Complete Picture rotates its correct option through indices 0, 2, 0, 2, 0.
    expect(find.text('You got 3 out of 5 correct.'), findsOneWidget);
  });


  testWidgets('completed game is saved and displayed in Rewards', (
    tester,
  ) async {
    final profileRepository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Ava', grade: 'Grade 1'),
    );
    final gameRepository = MemoryGameSessionRepository();

    await tester.pumpWidget(
      KidsGamesApp(
        profileRepository: profileRepository,
        gameSessionRepository: gameRepository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();

    final tile = find.byKey(const Key('activity_complete_picture'));
    await tester.tap(tile);
    await tester.pumpAndSettle();

    const correctAnswers = [0, 2, 0, 2, 0];
    for (var index = 0; index < correctAnswers.length; index++) {
      await tester.tap(find.byKey(Key('answer_${correctAnswers[index]}')));
      await tester.pumpAndSettle();
      final next = find.text(index == 4 ? 'See my score' : 'Next');
      await tester.ensureVisible(next);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
    }

    expect(find.text('You got 5 out of 5 correct.'), findsOneWidget);
    expect(find.text('Progress saved on this device.'), findsOneWidget);
    expect(await gameRepository.totalSessions(), 1);

    final progress = await gameRepository.progressFor('complete_picture');
    expect(progress.sessionsPlayed, 1);
    expect(progress.bestScore, 5);
    expect(progress.accuracy, 1);

    await tester.tap(find.text('Back to games'));
    await tester.pumpAndSettle();
    expect(find.text('Game world'), findsOneWidget);
    await tester.tap(find.text('Rewards').last);
    await tester.pumpAndSettle();

    expect(find.text('Your progress & rewards'), findsOneWidget);
    expect(find.text('Perfect Player'), findsOneWidget);
    expect(find.text('Complete Picture'), findsOneWidget);
    expect(find.text('5/5'), findsOneWidget);
  });

  testWidgets('Jigsaw Puzzles requires dragging every piece into its slot', (
    tester,
  ) async {
    final repository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Ava', grade: 'Grade 1'),
    );

    await tester.pumpWidget(KidsGamesApp(profileRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();

    final tile = find.byKey(const Key('activity_jigsaw_puzzles'));
    await tester.scrollUntilVisible(
      tile,
      400,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView).last,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.text('Build the sunny garden!'), findsOneWidget);

    final pieceIds = ['sun', 'cloud', 'tree', 'flower'];
    for (var index = 0; index < pieceIds.length; index++) {
      final id = pieceIds[index];
      final piece = find.byKey(Key('jigsaw_piece_$id'));
      final slot = find.byKey(Key('jigsaw_slot_$id'));
      await tester.ensureVisible(piece);
      await tester.pumpAndSettle();

      final start = tester.getCenter(piece);
      final end = tester.getCenter(slot);
      final gesture = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(Offset.lerp(start, end, 0.35)!);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(Offset.lerp(start, end, 0.7)!);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(end);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      if (index < pieceIds.length - 1) {
        expect(
          find.text('${index + 1}/4'),
          findsOneWidget,
          reason: 'Dragging the $id piece should fill its matching slot.',
        );
      } else {
        expect(
          find.text('Beautifully completed!'),
          findsOneWidget,
          reason: 'The final correct piece should complete the puzzle.',
        );
      }
    }

    expect(find.text('Beautifully completed!'), findsOneWidget);
    expect(find.text('Completed in 4 moves'), findsOneWidget);

    await tester.tap(find.byKey(const Key('replay_jigsaw_button')));
    await tester.pumpAndSettle();
    expect(find.text('Build the sunny garden!'), findsOneWidget);
    expect(find.text('0/4'), findsOneWidget);
  });
}
