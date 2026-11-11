import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/features/games/flame_counting_game_screen.dart';

void main() {
  testWidgets('Magic Counting opens the Flame garden game', (tester) async {
    await tester.view.setPhysicalSize(const Size(900, 1600));
    await tester.view.setDevicePixelRatio(1);
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
}
