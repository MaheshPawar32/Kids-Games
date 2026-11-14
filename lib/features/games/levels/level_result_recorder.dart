import '../../../data/repositories/game_session_repository.dart';
import '../../../data/repositories/level_progress_repository.dart';

/// Saves one finished level exactly once.
///
/// The session id is fixed when the level starts, so a retry after a storage
/// error overwrites the same record instead of adding a duplicate, and
/// progress keeps the best stars.
class LevelResultRecorder {
  LevelResultRecorder({
    required this.activityId,
    required this.level,
    required this.sessionRepository,
    required this.progressRepository,
  }) : sessionId =
           '${activityId}_L${level}_${DateTime.now().microsecondsSinceEpoch}';

  final String activityId;
  final int level;
  final GameSessionRepository sessionRepository;
  final LevelProgressRepository progressRepository;
  final String sessionId;

  bool _saved = false;
  bool get saved => _saved;

  Future<void> save({
    required int score,
    required int total,
    required int stars,
  }) async {
    if (_saved) return;
    await progressRepository.recordResult(activityId, level, stars);
    await sessionRepository.recordSession(
      GameSession(
        id: sessionId,
        activityId: activityId,
        score: score,
        totalRounds: total,
        completedAt: DateTime.now(),
        level: level,
      ),
    );
    _saved = true;
  }
}
