import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/create/create_studio_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('drawing studio supports undo redo and saves artwork locally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: CreateStudioScreen()),
    );
    await tester.pumpAndSettle();

    final canvas = find.byKey(const Key('create_drawing_canvas'));
    await tester.ensureVisible(canvas);
    await tester.pumpAndSettle();
    final center = tester.getCenter(canvas);
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.moveTo(center + const Offset(90, 24));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    final undo = find.byKey(const Key('create_undo_button'));
    await tester.scrollUntilVisible(undo, 250);
    await tester.tap(undo);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('create_redo_button')), findsOneWidget);

    final redo = find.byKey(const Key('create_redo_button'));
    await tester.scrollUntilVisible(redo, 250);
    await tester.tap(redo);
    await tester.pumpAndSettle();

    final save = find.byKey(const Key('create_save_button'));
    await tester.scrollUntilVisible(save, 250);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Save your picture'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Picture saved in your gallery.'), findsOneWidget);

    final gallery = find.byKey(const Key('create_gallery_button'));
    await tester.scrollUntilVisible(gallery, -250);
    await tester.tap(gallery);
    await tester.pumpAndSettle();
    expect(find.text('My gallery'), findsOneWidget);
    expect(find.text('My picture'), findsOneWidget);
  });
}
