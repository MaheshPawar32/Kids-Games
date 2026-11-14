import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../features/games/levels/game_level.dart';

/// Unlock state and best stars for one game's 1000-level map.
@immutable
class LevelProgress {
  const LevelProgress({
    required this.activityId,
    this.unlockedLevel = 1,
    this.stars = const {},
  });

  final String activityId;

  /// Highest level the child may play (levels 1..unlockedLevel).
  final int unlockedLevel;

  /// Best stars (1–3) per completed level.
  final Map<int, int> stars;

  int starsFor(int level) => stars[level] ?? 0;

  int get completedLevels => stars.length;

  int get totalStars => stars.values.fold(0, (sum, value) => sum + value);

  bool isUnlocked(int level) => level >= 1 && level <= unlockedLevel;

  /// Level the Continue button should open.
  int get nextLevel => unlockedLevel;

  static const schemaVersion = 1;

  Map<String, Object?> toMap() => {
    'schema_version': schemaVersion,
    'activity_id': activityId,
    'unlocked_level': unlockedLevel,
    'stars': {for (final entry in stars.entries) '${entry.key}': entry.value},
  };

  /// Reads stored progress, ignoring malformed fields instead of failing.
  factory LevelProgress.fromMap(String activityId, Object? raw) {
    if (raw is! Map) return LevelProgress(activityId: activityId);
    final unlocked = raw['unlocked_level'];
    final stars = <int, int>{};
    final rawStars = raw['stars'];
    if (rawStars is Map) {
      for (final entry in rawStars.entries) {
        final level = int.tryParse('${entry.key}');
        final value = entry.value;
        if (level != null && level >= 1 && value is int && value > 0) {
          stars[level] = value.clamp(1, 3);
        }
      }
    }
    return LevelProgress(
      activityId: activityId,
      unlockedLevel: unlocked is int ? unlocked.clamp(1, kLevelsPerGame) : 1,
      stars: stars,
    );
  }

  /// Applies a finished level; one star or more unlocks the next level.
  LevelProgress withResult(int level, int earnedStars) {
    if (level < 1 || level > unlockedLevel) return this;
    final nextStars = Map<int, int>.of(stars);
    if (earnedStars > (nextStars[level] ?? 0)) {
      nextStars[level] = earnedStars.clamp(1, 3);
    }
    final unlocks = earnedStars > 0 && level == unlockedLevel;
    return LevelProgress(
      activityId: activityId,
      unlockedLevel: unlocks
          ? (level + 1).clamp(1, kLevelsPerGame)
          : unlockedLevel,
      stars: nextStars,
    );
  }
}

abstract interface class LevelProgressRepository {
  ValueListenable<int> get revision;
  Future<LevelProgress> load(String activityId);
  Future<LevelProgress> recordResult(String activityId, int level, int stars);
}

class HiveLevelProgressRepository implements LevelProgressRepository {
  HiveLevelProgressRepository({Box<dynamic>? box}) : _providedBox = box;

  static const boxName = 'kids_games_levels';

  final Box<dynamic>? _providedBox;
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  Box<dynamic> get _box => _providedBox ?? Hive.box<dynamic>(boxName);

  @override
  ValueListenable<int> get revision => _revision;

  @override
  Future<LevelProgress> load(String activityId) async =>
      LevelProgress.fromMap(activityId, _box.get(activityId));

  @override
  Future<LevelProgress> recordResult(
    String activityId,
    int level,
    int stars,
  ) async {
    final next = (await load(activityId)).withResult(level, stars);
    await _box.put(activityId, next.toMap());
    await _box.flush();
    _revision.value++;
    return next;
  }
}

/// In-memory implementation for widget tests and previews.
class MemoryLevelProgressRepository implements LevelProgressRepository {
  MemoryLevelProgressRepository([Map<String, LevelProgress>? initial])
    : _progress = {...?initial};

  final Map<String, LevelProgress> _progress;
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  @override
  ValueListenable<int> get revision => _revision;

  @override
  Future<LevelProgress> load(String activityId) async =>
      _progress[activityId] ?? LevelProgress(activityId: activityId);

  @override
  Future<LevelProgress> recordResult(
    String activityId,
    int level,
    int stars,
  ) async {
    final next = (await load(activityId)).withResult(level, stars);
    _progress[activityId] = next;
    _revision.value++;
    return next;
  }
}
