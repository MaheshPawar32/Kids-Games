import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/app/kids_games_app.dart';
import 'package:kidsgames/features/onboarding/child_profile.dart';
import 'package:kidsgames/features/onboarding/child_profile_repository.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/data/repositories/level_progress_repository.dart';
import 'package:kidsgames/features/games/levels/level_generator.dart';
import 'package:kidsgames/features/parent/parent_access_repository.dart';

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

    await tester.pumpWidget(
      KidsGamesApp(
        profileRepository: repository,
        parentAccessRepository: MemoryParentAccessRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to your play world!'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('child_name_field')), 'Ava');
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

    await tester.pumpWidget(
      KidsGamesApp(
        profileRepository: repository,
        parentAccessRepository: MemoryParentAccessRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello, Leo!'), findsOneWidget);
    expect(find.text('Welcome to your play world!'), findsNothing);
  });

  testWidgets('bottom navigation switches to the games tab', (tester) async {
    final repository = _FakeChildProfileRepository(
      profile: const ChildProfile(name: 'Mia', grade: 'Grade 2'),
    );

    await tester.pumpWidget(
      KidsGamesApp(
        profileRepository: repository,
        parentAccessRepository: MemoryParentAccessRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();

    expect(find.text('Game world'), findsOneWidget);
    expect(find.text('Complete Picture'), findsOneWidget);
  });

  Future<void> openGame(WidgetTester tester, String id) async {
    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();
    final tile = find.byKey(Key('activity_$id'));
    await tester.scrollUntilVisible(
      tile,
      300,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView).last,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('a game opens its 1000-level map and Continue starts level 1', (
    tester,
  ) async {
    await tester.pumpWidget(
      KidsGamesApp(
        profileRepository: _FakeChildProfileRepository(
          profile: const ChildProfile(name: 'Sam', grade: 'Grade 1'),
        ),
        parentAccessRepository: MemoryParentAccessRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await openGame(tester, 'shape_matching');

    expect(find.text('0 of 1000 levels done'), findsOneWidget);
    expect(find.text('Start level 1'), findsOneWidget);
    expect(find.byKey(const Key('level_tile_1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('continue_level_button')));
    await tester.pumpAndSettle();
    expect(find.text('Shape Matching · Level 1'), findsOneWidget);
    final rounds = generateLevel('shape_matching', 1, grade: 'Grade 1');
    expect(find.text(rounds.first.prompt), findsOneWidget);
  });

  testWidgets('finishing a level saves stars, Next level opens level 2 and '
      'Rewards shows the game', (tester) async {
    final sessions = MemoryGameSessionRepository();
    final levels = MemoryLevelProgressRepository();
    await tester.pumpWidget(
      KidsGamesApp(
        profileRepository: _FakeChildProfileRepository(
          profile: const ChildProfile(name: 'Ava', grade: 'Grade 1'),
        ),
        parentAccessRepository: MemoryParentAccessRepository(),
        gameSessionRepository: sessions,
        levelProgressRepository: levels,
      ),
    );
    await tester.pumpAndSettle();
    await openGame(tester, 'complete_picture');
    await tester.tap(find.byKey(const Key('continue_level_button')));
    await tester.pumpAndSettle();

    final rounds = generateLevel('complete_picture', 1, grade: 'Grade 1');
    for (final round in rounds) {
      expect(find.text(round.prompt), findsOneWidget);
      final answer = find.byKey(Key('answer_${round.correctIndex}'));
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pump();
      expect(find.text('Amazing! ⭐'), findsOneWidget);
      // Correct answers advance automatically.
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();
    }

    expect(find.text('Level 1 complete!'), findsOneWidget);
    expect(
      find.text('You got ${rounds.length} out of ${rounds.length} right.'),
      findsOneWidget,
    );
    expect(find.text('Progress saved on this device.'), findsOneWidget);
    expect((await levels.load('complete_picture')).starsFor(1), 3);
    final saved = await sessions.recentSessions();
    expect(saved.single.level, 1);
    expect(saved.single.score, rounds.length);

    await tester.tap(find.byKey(const Key('next_level_button')));
    await tester.pumpAndSettle();
    expect(find.text('Complete Picture · Level 2'), findsOneWidget);

    // Back returns to the level map, not to level 1.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1 of 1000 levels done'), findsOneWidget);
    expect(find.text('Continue level 2'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rewards').last);
    await tester.pumpAndSettle();
    expect(find.text('Your progress & rewards'), findsOneWidget);
    expect(find.text('Perfect Player'), findsOneWidget);
    expect(find.text('${rounds.length}/${rounds.length}'), findsOneWidget);
  });
}
