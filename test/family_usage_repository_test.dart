import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/features/parent/family_usage_repository.dart';
import 'package:kidsgames/features/parent/parent_access_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('family usage repository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stores usage for today and resets on the next date', () async {
      final repository = PreferencesFamilyUsageRepository();
      final firstDay = DateTime(2026, 11, 11, 10);
      await repository.saveTodaySeconds(1250, firstDay);

      expect(await repository.loadTodaySeconds(firstDay), 1250);
      expect(
        await repository.loadTodaySeconds(DateTime(2026, 11, 12, 9)),
        0,
      );
    });

    test('clamps negative and excessive usage values', () async {
      final repository = PreferencesFamilyUsageRepository();
      final day = DateTime(2026, 11, 11);
      await repository.saveTodaySeconds(-5, day);
      expect(await repository.loadTodaySeconds(day), 0);

      await repository.saveTodaySeconds(999999, day);
      expect(await repository.loadTodaySeconds(day), 86400);
    });
  });

  group('bedtime policy', () {
    const daytime = ParentControls(
      bedtimeEnabled: true,
      bedtimeStartMinute: 8 * 60,
      bedtimeEndMinute: 20 * 60,
    );
    const overnight = ParentControls(
      bedtimeEnabled: true,
      bedtimeStartMinute: 20 * 60,
      bedtimeEndMinute: 7 * 60,
    );

    test('handles same-day bedtime window', () {
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 11, 7, 59), daytime), false);
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 11, 8), daytime), true);
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 11, 19, 59), daytime), true);
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 11, 20), daytime), false);
    });

    test('handles overnight bedtime window', () {
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 11, 19, 59), overnight), false);
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 11, 20), overnight), true);
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 12, 6, 59), overnight), true);
      expect(isWithinBedtimeSchedule(DateTime(2026, 11, 12, 7), overnight), false);
    });

    test('disabled schedule never blocks access', () {
      expect(
        isWithinBedtimeSchedule(
          DateTime(2026, 11, 11, 23),
          const ParentControls(bedtimeEnabled: false),
        ),
        false,
      );
    });
  });
}
