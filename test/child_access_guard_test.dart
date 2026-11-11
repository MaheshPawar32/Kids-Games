import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/parent/parent_access_repository.dart';
import 'package:kidsgames/features/parent/parent_screens.dart';

void main() {
  testWidgets('daily limit blocks child access and offers parent gate', (
    tester,
  ) async {
    final repository = MemoryParentAccessRepository();
    await repository.saveControls(
      const ParentControls(dailyLimitMinutes: 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChildAccessGuard(
          repository: repository,
          dailyUsageSeconds: 1800,
          onParentTap: () {},
          child: const Scaffold(body: Text('Child home')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Child home'), findsNothing);
    expect(find.text('Great play today!'), findsOneWidget);
    expect(find.byKey(const Key('time_limit_parent_button')), findsOneWidget);
  });

  testWidgets('bedtime schedule blocks child access', (tester) async {
    final repository = MemoryParentAccessRepository();
    await repository.saveControls(
      const ParentControls(
        bedtimeEnabled: true,
        bedtimeStartMinute: 0,
        bedtimeEndMinute: 1439,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChildAccessGuard(
          repository: repository,
          dailyUsageSeconds: 0,
          onParentTap: () {},
          child: const Scaffold(body: Text('Child home')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Child home'), findsNothing);
    expect(find.text('Bedtime now'), findsOneWidget);
  });

  testWidgets('child route remains available within family limits', (
    tester,
  ) async {
    final repository = MemoryParentAccessRepository();
    await repository.saveControls(
      const ParentControls(dailyLimitMinutes: 60),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChildAccessGuard(
          repository: repository,
          dailyUsageSeconds: 120,
          onParentTap: () {},
          child: const Scaffold(body: Text('Child home')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Child home'), findsOneWidget);
    expect(find.text('Great play today!'), findsNothing);
  });
}
