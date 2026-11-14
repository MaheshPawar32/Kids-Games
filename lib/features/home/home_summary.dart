import '../../data/repositories/game_session_repository.dart';
import '../../data/repositories/level_progress_repository.dart';
import '../games/activity.dart';

/// Home dashboard figures, derived only from saved sessions and progress.
class HomeSummary {
  const HomeSummary({
    required this.totalStars,
    required this.levelsToday,
    required this.continueActivity,
    required this.continueLevel,
  });

  static const dailyMissionTarget = 3;

  final int totalStars;

  /// Levels finished today (local date), counting replays.
  final int levelsToday;

  /// Most recently played game, or null before the first game.
  final Activity? continueActivity;
  final int continueLevel;

  bool get missionComplete => levelsToday >= dailyMissionTarget;

  static HomeSummary compute({
    required List<GameSession> sessions,
    required Map<String, LevelProgress> progress,
    required DateTime now,
  }) {
    bool sameDay(DateTime a) {
      final local = a.toLocal();
      return local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
    }

    final levelSessions = sessions.where((s) => s.level != null).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    Activity? last;
    if (levelSessions.isNotEmpty) {
      final id = levelSessions.first.activityId;
      for (final activity in starterActivities) {
        if (activity.id == id) last = activity;
      }
    }
    return HomeSummary(
      totalStars: progress.values.fold(0, (sum, p) => sum + p.totalStars),
      levelsToday: levelSessions.where((s) => sameDay(s.completedAt)).length,
      continueActivity: last,
      continueLevel: last == null ? 1 : progress[last.id]?.nextLevel ?? 1,
    );
  }
}
