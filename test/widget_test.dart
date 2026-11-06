import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/app/kids_games_app.dart';

void main() {
  testWidgets('shows the Kids Games home screen', (tester) async {
    await tester.pumpWidget(const KidsGamesApp());
    expect(find.text('Hello, Explorer!'), findsOneWidget);
    expect(find.text('Play & learn'), findsOneWidget);
    expect(find.text('Complete Picture'), findsOneWidget);
  });
}
