import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/parent/parent_access_repository.dart';

void main() {
  group('MemoryParentAccessRepository', () {
    test('stores and verifies a six-digit parent PIN', () async {
      final repository = MemoryParentAccessRepository();

      expect(await repository.hasPin(), isFalse);
      await repository.setPin('482615');

      expect(await repository.hasPin(), isTrue);
      expect(await repository.verifyPin('482615'), isTrue);
      expect(await repository.verifyPin('482614'), isFalse);
      expect(await repository.verifyPin('abc'), isFalse);
    });

    test('persists family controls in the repository', () async {
      final repository = MemoryParentAccessRepository();
      const controls = ParentControls(
        dailyLimitMinutes: 45,
        bedtimeEnabled: true,
        bedtimeStartMinute: 21 * 60,
        bedtimeEndMinute: 6 * 60 + 30,
        soundEnabled: false,
        reducedMotion: true,
      );

      await repository.saveControls(controls);
      final restored = await repository.loadControls();

      expect(restored.dailyLimitMinutes, 45);
      expect(restored.bedtimeEnabled, isTrue);
      expect(restored.bedtimeStartMinute, 21 * 60);
      expect(restored.bedtimeEndMinute, 6 * 60 + 30);
      expect(restored.soundEnabled, isFalse);
      expect(restored.reducedMotion, isTrue);
    });
  });
}
