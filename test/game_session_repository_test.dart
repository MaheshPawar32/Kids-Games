import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:kidsgames/data/repositories/game_session_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late HiveGameSessionRepository repository;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('kids_games_hive_test_');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>('session_repository_test');
    repository = HiveGameSessionRepository(box: box);
  });

  setUp(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test('records sessions and flushes them to the local Hive box', () async {
    final completedAt = DateTime(2026, 11, 10, 12);
    await repository.recordSession(
      GameSession(
        id: 'complete_picture_1',
        activityId: 'complete_picture',
        score: 4,
        totalRounds: 5,
        completedAt: completedAt,
      ),
    );

    expect(box.length, 1);
    expect(repository.revision.value, 1);

    final history = await repository.recentSessions();
    expect(history, hasLength(1));
    expect(history.single.activityId, 'complete_picture');
    expect(history.single.score, 4);
    expect(history.single.totalRounds, 5);
    expect(history.single.completedAt, completedAt);
  });

  test('aggregates best score and accuracy per activity', () async {
    await repository.recordSession(
      GameSession(
        id: 'animal_1',
        activityId: 'animal_recognition',
        score: 3,
        totalRounds: 5,
        completedAt: DateTime(2026, 11, 9),
      ),
    );
    await repository.recordSession(
      GameSession(
        id: 'animal_2',
        activityId: 'animal_recognition',
        score: 5,
        totalRounds: 5,
        completedAt: DateTime(2026, 11, 10),
      ),
    );

    final progress = await repository.progressFor('animal_recognition');
    expect(progress.sessionsPlayed, 2);
    expect(progress.bestScore, 5);
    expect(progress.totalCorrect, 8);
    expect(progress.totalQuestions, 10);
    expect(progress.accuracy, 0.8);
    expect(progress.lastPlayedAt, DateTime(2026, 11, 10));
    expect(await repository.totalSessions(), 2);
  });

  test('returns recent sessions newest first and respects the limit', () async {
    for (var day = 1; day <= 3; day++) {
      await repository.recordSession(
        GameSession(
          id: 'session_$day',
          activityId: 'magic_counting',
          score: day,
          totalRounds: 5,
          completedAt: DateTime(2026, 11, day),
        ),
      );
    }

    final recent = await repository.recentSessions(limit: 2);
    expect(recent.map((item) => item.id), ['session_3', 'session_2']);
    expect(await repository.recentSessions(limit: 0), isEmpty);
  });

  test(
    'memory repository notifies listeners when a session is saved',
    () async {
      final memory = MemoryGameSessionRepository();
      var notifications = 0;
      memory.revision.addListener(() => notifications++);

      await memory.recordSession(
        GameSession(
          id: 'shape_1',
          activityId: 'shape_matching',
          score: 5,
          totalRounds: 5,
          completedAt: DateTime(2026, 11, 10),
        ),
      );

      expect(notifications, 1);
      expect(await memory.totalSessions(), 1);
    },
  );
}
