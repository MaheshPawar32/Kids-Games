import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/repositories/level_progress_repository.dart';
import '../activity.dart';
import 'game_level.dart';

/// The 1000-level map for one game: continue, replay and stars per level.
class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({
    required this.activity,
    required this.progressRepository,
    required this.onPlayLevel,
    this.grade,
    super.key,
  });

  final Activity activity;
  final LevelProgressRepository progressRepository;
  final ValueChanged<int> onPlayLevel;
  final String? grade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(title: Text(activity.title)),
      body: ValueListenableBuilder<int>(
        valueListenable: progressRepository.revision,
        builder: (context, _, _) => FutureBuilder<LevelProgress>(
          future: progressRepository.load(activity.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Your levels could not be loaded.'),
              );
            }
            final progress = snapshot.data;
            if (progress == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _LevelMap(
              activity: activity,
              progress: progress,
              grade: grade,
              onPlayLevel: onPlayLevel,
            );
          },
        ),
      ),
    );
  }
}

class _LevelMap extends StatefulWidget {
  const _LevelMap({
    required this.activity,
    required this.progress,
    required this.onPlayLevel,
    this.grade,
  });

  final Activity activity;
  final LevelProgress progress;
  final ValueChanged<int> onPlayLevel;
  final String? grade;

  @override
  State<_LevelMap> createState() => _LevelMapState();
}

class _LevelMapState extends State<_LevelMap> {
  static const _columns = 5;
  static const _rowHeight = 78.0;
  late final ScrollController _scroll = ScrollController(
    // Open near the child's current level.
    initialScrollOffset:
        ((widget.progress.nextLevel - 1) ~/ _columns - 1).clamp(0, 1 << 20) *
        _rowHeight,
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final next = progress.nextLevel;
    final color = Color(widget.activity.colorValue);
    final tier = GameDifficulty(level: next, grade: widget.grade).tier;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Color.lerp(color, Colors.white, 0.6)!],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Text(
                  widget.activity.emoji,
                  style: const TextStyle(fontSize: 44),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.completedLevels} of $kLevelsPerGame '
                        'levels done',
                        key: const Key('levels_done_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '⭐ ${progress.totalStars} stars · '
                        'Difficulty ${'●' * tier}${'○' * (10 - tier)}',
                        style: const TextStyle(color: AppTheme.ink),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        key: const Key('continue_level_button'),
                        onPressed: () => widget.onPlayLevel(next),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          progress.completedLevels == 0
                              ? 'Start level 1'
                              : 'Continue level $next',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            key: const Key('level_grid'),
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            itemCount: kLevelsPerGame,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              mainAxisExtent: _rowHeight - 10,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => _LevelTile(
              level: index + 1,
              unlocked: progress.isUnlocked(index + 1),
              stars: progress.starsFor(index + 1),
              current: index + 1 == next,
              color: color,
              onTap: () => widget.onPlayLevel(index + 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.current,
    required this.color,
    required this.onTap,
  });

  final int level;
  final bool unlocked;
  final int stars;
  final bool current;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = unlocked
        ? 'Level $level, ${stars == 0 ? 'not finished' : '$stars stars'}'
        : 'Level $level, locked';
    return Semantics(
      button: unlocked,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: !unlocked
            ? const Color(0xFFE9ECF3)
            : current
            ? color
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          key: Key('level_tile_$level'),
          borderRadius: BorderRadius.circular(18),
          onTap: unlocked ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: current
                  ? Border.all(color: AppTheme.ink, width: 2.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (unlocked)
                  FittedBox(
                    child: Text(
                      '$level',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppTheme.ink,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: Color(0xFFA3ACC2),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: i < stars
                            ? const Color(0xFFFFB31A)
                            : const Color(0xFFD5DAE5),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
