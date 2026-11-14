import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../data/repositories/game_session_repository.dart';
import '../../data/repositories/level_progress_repository.dart';
import '../games/activity.dart';
import 'home_summary.dart';

/// Continue-playing card and daily mission, backed by saved progress.
class TodayPanel extends StatelessWidget {
  const TodayPanel({
    required this.sessionRepository,
    required this.progressRepository,
    super.key,
  });

  final GameSessionRepository sessionRepository;
  final LevelProgressRepository progressRepository;

  Future<HomeSummary> _load() async {
    final sessions = await sessionRepository.recentSessions(limit: 500);
    final progress = <String, LevelProgress>{
      for (final activity in starterActivities)
        activity.id: await progressRepository.load(activity.id),
    };
    return HomeSummary.compute(
      sessions: sessions,
      progress: progress,
      now: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _Merged(
        sessionRepository.revision,
        progressRepository.revision,
      ),
      builder: (context, _, _) => FutureBuilder<HomeSummary>(
        future: _load(),
        builder: (context, snapshot) {
          final summary = snapshot.data;
          if (summary == null) {
            return const SizedBox(
              height: 230,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Column(
            children: [
              _continueCard(context, summary),
              const SizedBox(height: 12),
              _missionCard(summary),
            ],
          );
        },
      ),
    );
  }

  Widget _continueCard(BuildContext context, HomeSummary summary) {
    final activity = summary.continueActivity ?? starterActivities.first;
    final firstTime = summary.continueActivity == null;
    final level = summary.continueLevel;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF72CFF2), Color(0xFF9B8BF0)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2672BFE8),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstTime ? 'Start your adventure' : 'Continue playing',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity.emoji} ${activity.title}',
                    key: const Key('continue_game_title'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Level $level · ⭐ ${summary.totalStars} stars',
                    key: const Key('home_total_stars'),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('continue_playing_button'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC94F),
                      foregroundColor: AppTheme.ink,
                    ),
                    onPressed: () => context.push<void>(
                      '/games/${activity.id}/level/$level',
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(firstTime ? 'Play now' : 'Play level $level'),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              height: 110,
              child: SvgPicture.asset(
                'assets/characters/fox_buddy.svg',
                semanticsLabel: 'Fox buddy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _missionCard(HomeSummary summary) {
    const target = HomeSummary.dailyMissionTarget;
    final done = summary.levelsToday.clamp(0, target);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Text(
            summary.missionComplete ? '🏅' : '🎯',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.missionComplete
                      ? 'Daily mission complete!'
                      : 'Daily mission: finish $target levels',
                  key: const Key('daily_mission_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: done / target,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFEDEFF6),
                    color: const Color(0xFF66C99B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$done/$target',
            key: const Key('daily_mission_progress'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// Notifies when either repository changes.
class _Merged extends ChangeNotifier implements ValueListenable<int> {
  _Merged(this._a, this._b);

  final ValueListenable<int> _a;
  final ValueListenable<int> _b;

  @override
  int get value => _a.value * 100003 + _b.value;

  @override
  void addListener(VoidCallback listener) {
    _a.addListener(listener);
    _b.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _a.removeListener(listener);
    _b.removeListener(listener);
  }
}
