import 'package:flutter_test/flutter_test.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';
import 'package:kidsgames/data/repositories/level_progress_repository.dart';
import 'package:kidsgames/features/home/home_summary.dart';

GameSession _session(String activity, DateTime at, {int? level = 1}) =>
    GameSession(
      id: '$activity$at',
      activityId: activity,
      score: 5,
      totalRounds: 5,
      completedAt: at,
      level: level,
    );

void main() {
  final now = DateTime(2026, 11, 14, 18);

  test('first launch suggests the first game and an empty mission', () {
    final summary = HomeSummary.compute(
      sessions: const [],
      progress: const {},
      now: now,
    );
    expect(summary.continueActivity, isNull);
    expect(summary.continueLevel, 1);
    expect(summary.levelsToday, 0);
    expect(summary.totalStars, 0);
    expect(summary.missionComplete, isFalse);
  });

  test('continue opens the next level of the most recently played game', () {
    final summary = HomeSummary.compute(
      sessions: [
        _session('color_matching', now.subtract(const Duration(hours: 3))),
        _session('big_small', now.subtract(const Duration(hours: 1))),
      ],
      progress: const {
        'big_small': LevelProgress(
          activityId: 'big_small',
          unlockedLevel: 8,
          stars: {1: 3, 2: 2},
        ),
        'color_matching': LevelProgress(
          activityId: 'color_matching',
          unlockedLevel: 2,
          stars: {1: 1},
        ),
      },
      now: now,
    );
    expect(summary.continueActivity!.id, 'big_small');
    expect(summary.continueLevel, 8);
    expect(summary.totalStars, 6);
  });

  test('daily mission counts only today and only level sessions', () {
    final summary = HomeSummary.compute(
      sessions: [
        _session('a', now.subtract(const Duration(hours: 2))),
        _session('b', now.subtract(const Duration(hours: 1))),
        _session('c', DateTime(2026, 11, 13, 23, 59)),
        // Sessions saved before levels existed have no level.
        _session('d', now, level: null),
      ],
      progress: const {},
      now: now,
    );
    expect(summary.levelsToday, 2);
    expect(summary.missionComplete, isFalse);

    final complete = HomeSummary.compute(
      sessions: [
        for (var i = 0; i < 4; i++)
          _session('a$i', now.subtract(Duration(minutes: i))),
      ],
      progress: const {},
      now: now,
    );
    expect(complete.missionComplete, isTrue);
  });
}
