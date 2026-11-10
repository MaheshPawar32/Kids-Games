import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';

class GameSession {
  const GameSession({
    required this.id,
    required this.activityId,
    required this.score,
    required this.totalRounds,
    required this.completedAt,
  });

  final String id;
  final String activityId;
  final int score;
  final int totalRounds;
  final DateTime completedAt;

  double get accuracy => totalRounds == 0 ? 0 : score / totalRounds;

  Map<String, Object?> toMap() => {
        'id': id,
        'activity_id': activityId,
        'score': score,
        'total_rounds': totalRounds,
        'completed_at_micros': completedAt.microsecondsSinceEpoch,
      };

  factory GameSession.fromMap(Map<dynamic, dynamic> map) {
    final micros = map['completed_at_micros'];
    return GameSession(
      id: map['id'] as String,
      activityId: map['activity_id'] as String,
      score: (map['score'] as num).toInt(),
      totalRounds: (map['total_rounds'] as num).toInt(),
      completedAt: DateTime.fromMicrosecondsSinceEpoch((micros as num).toInt()),
    );
  }
}

class ActivityProgress {
  const ActivityProgress({
    required this.activityId,
    required this.sessionsPlayed,
    required this.bestScore,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.lastPlayedAt,
  });

  final String activityId;
  final int sessionsPlayed;
  final int bestScore;
  final int totalCorrect;
  final int totalQuestions;
  final DateTime? lastPlayedAt;

  double get accuracy =>
      totalQuestions == 0 ? 0 : totalCorrect / totalQuestions;

  static ActivityProgress empty(String activityId) => ActivityProgress(
        activityId: activityId,
        sessionsPlayed: 0,
        bestScore: 0,
        totalCorrect: 0,
        totalQuestions: 0,
        lastPlayedAt: null,
      );
}

abstract interface class GameSessionRepository {
  ValueListenable<int> get revision;
  Future<void> recordSession(GameSession session);
  Future<List<GameSession>> recentSessions({int limit = 20});
  Future<ActivityProgress> progressFor(String activityId);
  Future<int> totalSessions();
}

class HiveGameSessionRepository implements GameSessionRepository {
  HiveGameSessionRepository({Box<dynamic>? box}) : _providedBox = box;

  static const boxName = 'kids_games_sessions';

  final Box<dynamic>? _providedBox;
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  @override
  ValueListenable<int> get revision => _revision;

  Box<dynamic> get _box =>
      _providedBox ?? Hive.box<dynamic>(boxName);

  @override
  Future<void> recordSession(GameSession session) async {
    await _box.put(session.id, session.toMap());
    await _box.flush();
    _revision.value++;
  }

  List<GameSession> _allSessions() {
    final sessions = <GameSession>[];
    for (final raw in _box.values) {
      if (raw is Map) {
        try {
          sessions.add(GameSession.fromMap(raw));
        } on Object {
          // Ignore malformed legacy entries rather than losing all history.
        }
      }
    }
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  @override
  Future<List<GameSession>> recentSessions({int limit = 20}) async {
    if (limit <= 0) return const [];
    return _allSessions().take(limit).toList(growable: false);
  }

  @override
  Future<ActivityProgress> progressFor(String activityId) async {
    final sessions =
        _allSessions().where((session) => session.activityId == activityId);
    var plays = 0;
    var best = 0;
    var correct = 0;
    var questions = 0;
    DateTime? lastPlayed;
    for (final session in sessions) {
      plays++;
      if (session.score > best) best = session.score;
      correct += session.score;
      questions += session.totalRounds;
      if (lastPlayed == null || session.completedAt.isAfter(lastPlayed)) {
        lastPlayed = session.completedAt;
      }
    }
    if (plays == 0) return ActivityProgress.empty(activityId);
    return ActivityProgress(
      activityId: activityId,
      sessionsPlayed: plays,
      bestScore: best,
      totalCorrect: correct,
      totalQuestions: questions,
      lastPlayedAt: lastPlayed,
    );
  }

  @override
  Future<int> totalSessions() async => _box.length;
}

/// A lightweight in-memory implementation used by widget tests and previews.
/// Production startup injects the Hive CE repository.
class MemoryGameSessionRepository implements GameSessionRepository {
  final List<GameSession> _sessions = [];
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  @override
  ValueListenable<int> get revision => _revision;

  @override
  Future<void> recordSession(GameSession session) async {
    _sessions.removeWhere((item) => item.id == session.id);
    _sessions.add(session);
    _revision.value++;
  }

  @override
  Future<List<GameSession>> recentSessions({int limit = 20}) async {
    final sessions = [..._sessions]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions.take(limit < 0 ? 0 : limit).toList(growable: false);
  }

  @override
  Future<ActivityProgress> progressFor(String activityId) async {
    final sessions =
        _sessions.where((session) => session.activityId == activityId);
    var plays = 0;
    var best = 0;
    var correct = 0;
    var questions = 0;
    DateTime? lastPlayed;
    for (final session in sessions) {
      plays++;
      if (session.score > best) best = session.score;
      correct += session.score;
      questions += session.totalRounds;
      if (lastPlayed == null || session.completedAt.isAfter(lastPlayed)) {
        lastPlayed = session.completedAt;
      }
    }
    if (plays == 0) return ActivityProgress.empty(activityId);
    return ActivityProgress(
      activityId: activityId,
      sessionsPlayed: plays,
      bestScore: best,
      totalCorrect: correct,
      totalQuestions: questions,
      lastPlayedAt: lastPlayed,
    );
  }

  @override
  Future<int> totalSessions() async => _sessions.length;
}
