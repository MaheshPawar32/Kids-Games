import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/app/kids_games_app.dart';
import 'package:kidsgames/features/onboarding/child_profile.dart';
import 'package:kidsgames/features/onboarding/child_profile_repository.dart';

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

    final shapeTile = find.byKey(const Key('activity_shape_matching'));
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
      await tester.tap(next);
      await tester.pumpAndSettle();
    }

    expect(find.text('Wonderful work!'), findsOneWidget);
    expect(find.text('You got 5 out of 5 correct.'), findsOneWidget);
  });

}
