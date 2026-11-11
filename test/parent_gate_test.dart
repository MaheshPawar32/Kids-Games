import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/app/kids_games_app.dart';
import 'package:kidsgames/features/onboarding/child_profile.dart';
import 'package:kidsgames/features/onboarding/child_profile_repository.dart';
import 'package:kidsgames/features/parent/parent_access_repository.dart';

class _ProfileRepository implements ChildProfileRepository {
  @override
  Future<void> clearProfile() async {}

  @override
  Future<ChildProfile?> loadProfile() async =>
      const ChildProfile(name: 'Ava', grade: 'Grade 1');

  @override
  Future<void> saveProfile(ChildProfile profile) async {}
}

Future<void> _completeAdultCheck(WidgetTester tester) async {
  final challenge = tester.widget<Text>(find.textContaining('× = ?')).data!;
  final match = RegExp(r'(\d+) × (\d+) = \?').firstMatch(challenge)!;
  final answer = int.parse(match.group(1)!) * int.parse(match.group(2)!);
  await tester.enterText(find.byKey(const Key('parent_adult_answer')), '$answer');
  await tester.tap(find.byKey(const Key('parent_gate_continue')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('parent area requires adult check, PIN creation and PIN unlock',
      (tester) async {
    final parentRepository = MemoryParentAccessRepository();
    await tester.pumpWidget(KidsGamesApp(
      profileRepository: _ProfileRepository(),
      parentAccessRepository: parentRepository,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Parent area'));
    await tester.pumpAndSettle();
    expect(find.text('A quick adult check'), findsOneWidget);

    await _completeAdultCheck(tester);
    expect(find.text('Create your parent PIN'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('parent_pin_field')), '482615');
    await tester.tap(find.byKey(const Key('parent_gate_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm your parent PIN'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('parent_pin_field')), '482615');
    await tester.tap(find.byKey(const Key('parent_gate_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Parent dashboard'), findsOneWidget);
    expect(find.text('Family settings'), findsOneWidget);
    expect(await parentRepository.hasPin(), isTrue);

    await tester.tap(find.byKey(const Key('parent_lock_button')));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Ava!'), findsOneWidget);

    await tester.tap(find.byTooltip('Parent area'));
    await tester.pumpAndSettle();
    await _completeAdultCheck(tester);
    expect(find.text('Enter your parent PIN'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('parent_pin_field')), '482615');
    await tester.tap(find.byKey(const Key('parent_gate_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Parent dashboard'), findsOneWidget);
  });
}