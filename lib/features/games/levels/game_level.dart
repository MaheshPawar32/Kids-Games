import 'dart:math' as math;

/// Number of curated, auto-generated levels per game.
///
/// The generators are deterministic for any positive level, so play can
/// continue beyond this number; the level map and progression cap here.
const int kLevelsPerGame = 1000;

/// Learning grades in the order offered during onboarding.
const kGrades = <String>[
  'Nursery',
  'LKG',
  'UKG',
  'Grade 1',
  'Grade 2',
  'Grade 3',
  'Grade 4',
  'Grade 5',
];

int gradeIndexOf(String? grade) {
  final index = kGrades.indexOf(grade ?? '');
  return index < 0 ? 0 : index;
}

/// Difficulty for one level, derived from the level number and the child's
/// grade.
///
/// [tier] (1–10) selects which question types appear. [progress] (0–1) grows
/// smoothly across all 1000 levels so number ranges and timings keep rising
/// within a tier instead of jumping.
class GameDifficulty {
  GameDifficulty({required int level, String? grade})
    : level = level < 1 ? 1 : level,
      gradeIndex = gradeIndexOf(grade);

  final int level;
  final int gradeIndex;

  /// 0.0 at level 1, 1.0 at level 1000 and beyond.
  double get progress =>
      ((level - 1) / (kLevelsPerGame - 1)).clamp(0.0, 1.0).toDouble();

  /// Older children start a few tiers higher (Grade 5 starts at tier 4).
  int get gradeBoost => (gradeIndex * 3) ~/ 7;

  /// Ease-out curve: early levels climb quickly, later levels refine.
  int get tier {
    final base = 1 + (9 * math.pow(progress, 0.6)).floor();
    return (base + gradeBoost).clamp(1, 10).toInt();
  }

  int get optionCount => tier <= 2
      ? 3
      : tier <= 7
      ? 4
      : 6;

  int get roundCount => tier <= 3
      ? 5
      : tier <= 6
      ? 6
      : 8;

  /// Linear interpolation helper for smoothly scaling numeric parameters.
  int scale(int from, int to) => (from + (to - from) * progress).round();
}

/// Stars earned for [correct] answers out of [total]; 0 means retry.
int starsFor(int correct, int total) {
  if (total <= 0) return 0;
  final ratio = correct / total;
  if (ratio >= 0.9) return 3;
  if (ratio >= 0.7) return 2;
  if (ratio >= 0.5) return 1;
  return 0;
}

/// Stable 32-bit seed for (activity, level, grade) so every level replays the
/// same content on every device.
int levelSeed(String activityId, int level, int gradeIndex) {
  var hash = 0x811C9DC5;
  for (final unit in '$activityId#$level#$gradeIndex'.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
