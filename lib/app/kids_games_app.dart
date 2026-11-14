import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/services/app_services.dart';
import '../data/repositories/game_session_repository.dart';
import '../data/repositories/level_progress_repository.dart';
import '../features/games/activity.dart';
import '../features/games/flame_counting_game_screen.dart';
import '../features/games/jigsaw_puzzles/jigsaw_puzzles_game_screen.dart';
import '../features/games/levels/game_level.dart';
import '../features/games/levels/level_game_screen.dart';
import '../features/games/levels/level_map_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/child_profile.dart';
import '../features/onboarding/child_profile_repository.dart';
import '../features/onboarding/child_setup_screen.dart';
import '../features/parent/parent_access_repository.dart';
import '../features/parent/parent_screens.dart';
import '../features/parent/family_usage_repository.dart';
import 'store/kids_games_store.dart';
import 'theme/app_theme.dart';

class KidsGamesApp extends StatefulWidget {
  const KidsGamesApp({
    this.profileRepository,
    this.gameSessionRepository,
    this.parentAccessRepository,
    this.levelProgressRepository,
    this.soundPlayerFactory,
    super.key,
  });

  final ChildProfileRepository? profileRepository;
  final GameSessionRepository? gameSessionRepository;
  final ParentAccessRepository? parentAccessRepository;
  final LevelProgressRepository? levelProgressRepository;

  /// Creates the sound player; [isEnabled] reflects the parent setting.
  /// Defaults to silence so tests and previews never touch audio plugins.
  final SoundPlayer Function(bool Function() isEnabled)? soundPlayerFactory;

  @override
  State<KidsGamesApp> createState() => _KidsGamesAppState();
}

class _KidsGamesAppState extends State<KidsGamesApp>
    with WidgetsBindingObserver {
  late final ChildProfileRepository _profileRepository =
      widget.profileRepository ?? PreferencesChildProfileRepository();
  final KidsGamesStore _store = KidsGamesStore();
  late final GameSessionRepository _gameSessionRepository =
      widget.gameSessionRepository ?? MemoryGameSessionRepository();
  late final ParentAccessRepository _parentAccessRepository =
      widget.parentAccessRepository ?? SecureParentAccessRepository();
  late final LevelProgressRepository _levelProgressRepository =
      widget.levelProgressRepository ?? MemoryLevelProgressRepository();
  late final SoundPlayer _sounds =
      widget.soundPlayerFactory?.call(() => _controls.soundEnabled) ??
      const SilentSoundPlayer();
  ParentControls _controls = const ParentControls();
  final FamilyUsageRepository _familyUsageRepository =
      PreferencesFamilyUsageRepository();
  int _dailyUsageSeconds = 0;
  late String _usageDayKey;
  DateTime? _usageIntervalStartedAt;
  Timer? _usageTimer;
  final ValueNotifier<int> _routerRefresh = ValueNotifier<int>(0);

  GoRouter? _router;
  ChildProfile? _profile;
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _parentUnlocked = false;
  bool _isDisposing = false;

  GoRouter get _appRouter => _router ??= _createRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usageDayKey = _dateKey(DateTime.now());
    _loadProfile();
    _refreshDailyUsage();
    _loadControls();
    _startUsageTracking();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final backgrounded =
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
    if (backgrounded) {
      _recordUsageInterval();
      _usageTimer?.cancel();
      _usageTimer = null;
      if (_parentUnlocked && mounted) {
        setState(() => _parentUnlocked = false);
        _routerRefresh.value++;
        _router?.go('/home');
      }
    } else if (state == AppLifecycleState.resumed) {
      _startUsageTracking();
    }
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  /// Loads parent settings that change the child experience (sound and
  /// reduced motion).
  Future<void> _loadControls() async {
    try {
      final controls = await _parentAccessRepository.loadControls();
      if (mounted) setState(() => _controls = controls);
    } catch (_) {
      // Defaults remain in effect when settings cannot be read.
    }
  }

  void _onControlsChanged() {
    _refreshDailyUsage();
    _loadControls();
  }

  Future<void> _refreshDailyUsage() async {
    final now = DateTime.now();
    final today = _dateKey(now);
    try {
      final seconds = await _familyUsageRepository.loadTodaySeconds(now);
      if (!mounted) return;
      setState(() {
        _usageDayKey = today;
        _dailyUsageSeconds = seconds;
      });
      _routerRefresh.value++;
    } catch (_) {
      // Usage tracking is best-effort; app access remains available offline.
    }
  }

  void _startUsageTracking() {
    if (_usageTimer != null) return;
    _usageIntervalStartedAt = DateTime.now();
    _usageTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _recordUsageInterval(),
    );
  }

  void _recordUsageInterval() {
    final started = _usageIntervalStartedAt;
    if (started == null) return;
    final now = DateTime.now();
    final seconds = now.difference(started).inSeconds;
    if (seconds <= 0) return;
    _usageIntervalStartedAt = now;
    final today = _dateKey(now);
    if (_usageDayKey != today) {
      _usageDayKey = today;
      _dailyUsageSeconds = 0;
    }
    _dailyUsageSeconds = (_dailyUsageSeconds + seconds)
        .clamp(0, 24 * 60 * 60)
        .toInt();
    if (mounted && !_isDisposing) {
      setState(() {});
      // Re-evaluate the child route guard as soon as a time limit is reached.
      _routerRefresh.value++;
    }
    unawaited(
      _familyUsageRepository
          .saveTodaySeconds(_dailyUsageSeconds, now)
          .catchError((Object _) {
            // A storage failure must not crash play; the next interval retries.
          }),
    );
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
      _routerRefresh.value++;
    }

    try {
      final profile = await _profileRepository.loadProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
      _routerRefresh.value++;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLoadError = true;
        _isLoading = false;
      });
      _routerRefresh.value++;
    }
  }

  Future<void> _saveProfile(ChildProfile profile) async {
    await _profileRepository.saveProfile(profile);
    if (!mounted) return;
    setState(() => _profile = profile);
    _routerRefresh.value++;
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/loading',
      refreshListenable: _routerRefresh,
      redirect: (context, state) {
        final currentPath = state.matchedLocation;

        if (_isLoading) {
          return currentPath == '/loading' ? null : '/loading';
        }

        if (_hasLoadError) {
          return currentPath == '/error' ? null : '/error';
        }

        if (_profile == null) {
          return currentPath == '/setup' ? null : '/setup';
        }

        if (currentPath == '/parent' && !_parentUnlocked) {
          return '/parent-gate';
        }

        if (currentPath == '/parent-gate' && _parentUnlocked) {
          return '/parent';
        }

        if (currentPath == '/loading' ||
            currentPath == '/setup' ||
            currentPath == '/error') {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => const _AppLoadingScreen(),
        ),
        GoRoute(
          path: '/error',
          builder: (context, state) =>
              _ProfileLoadErrorScreen(onRetry: _loadProfile),
        ),
        GoRoute(
          path: '/setup',
          builder: (context, state) =>
              ChildSetupScreen(onComplete: _saveProfile),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final profile = _profile;
            if (profile == null) {
              return const _AppLoadingScreen();
            }
            return _guardChildRoute(
              context,
              HomeScreen(
                childName: profile.name,
                grade: profile.grade,
                gameSessionRepository: _gameSessionRepository,
                levelProgressRepository: _levelProgressRepository,
              ),
            );
          },
        ),
        GoRoute(
          path: '/parent-gate',
          builder: (context, state) => ParentGateScreen(
            repository: _parentAccessRepository,
            onAuthenticated: () => _unlockParent(context),
          ),
        ),
        GoRoute(
          path: '/parent',
          builder: (context, state) => ParentDashboardScreen(
            parentRepository: _parentAccessRepository,
            gameSessionRepository: _gameSessionRepository,
            onLock: () => _lockParent(context),
            dailyUsageSeconds: _dailyUsageSeconds,
            onControlsChanged: _onControlsChanged,
          ),
        ),
        GoRoute(
          path: '/games/:activityId',
          builder: (context, state) {
            final activity = _activityFor(state.pathParameters['activityId']);
            if (activity == null) return const _UnknownActivityScreen();
            return _guardChildRoute(
              context,
              LevelMapScreen(
                activity: activity,
                grade: _profile?.grade,
                progressRepository: _levelProgressRepository,
                onPlayLevel: (level) =>
                    context.push<void>('/games/${activity.id}/level/$level'),
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'level/:level',
              builder: (context, state) {
                final activity = _activityFor(
                  state.pathParameters['activityId'],
                );
                final level = int.tryParse(state.pathParameters['level'] ?? '');
                if (activity == null ||
                    level == null ||
                    level < 1 ||
                    level > kLevelsPerGame) {
                  return const _UnknownActivityScreen();
                }
                // Replacing keeps Back pointing at the level map.
                void openLevel(int next) => context.pushReplacement(
                  '/games/${activity.id}/level/$next',
                );
                final grade = _profile?.grade;
                final Widget screen = switch (activity.id) {
                  'magic_counting' => FlameCountingGameScreen(
                    key: ValueKey('magic_counting_$level'),
                    level: level,
                    grade: grade,
                    sessionRepository: _gameSessionRepository,
                    progressRepository: _levelProgressRepository,
                    onNextLevel: openLevel,
                  ),
                  'jigsaw_puzzles' => JigsawPuzzlesGameScreen(
                    key: ValueKey('jigsaw_$level'),
                    level: level,
                    grade: grade,
                    sessionRepository: _gameSessionRepository,
                    progressRepository: _levelProgressRepository,
                    onNextLevel: openLevel,
                  ),
                  _ => LevelGameScreen(
                    key: ValueKey('${activity.id}_$level'),
                    activity: activity,
                    level: level,
                    grade: grade,
                    sessionRepository: _gameSessionRepository,
                    progressRepository: _levelProgressRepository,
                    onNextLevel: openLevel,
                  ),
                };
                return _guardChildRoute(context, screen);
              },
            ),
          ],
        ),
      ],
    );
  }

  Activity? _activityFor(String? id) {
    for (final activity in starterActivities) {
      if (activity.id == id) return activity;
    }
    return null;
  }

  Widget _guardChildRoute(BuildContext context, Widget child) {
    return ChildAccessGuard(
      repository: _parentAccessRepository,
      dailyUsageSeconds: _dailyUsageSeconds,
      child: child,
      onParentTap: () => context.push<void>('/parent-gate'),
    );
  }

  void _unlockParent(BuildContext context) {
    setState(() => _parentUnlocked = true);
    _routerRefresh.value++;
    context.go('/parent');
  }

  void _lockParent(BuildContext context) {
    setState(() => _parentUnlocked = false);
    _routerRefresh.value++;
    context.go('/home');
  }

  @override
  void dispose() {
    _isDisposing = true;
    _usageTimer?.cancel();
    _usageTimer = null;
    _recordUsageInterval();
    WidgetsBinding.instance.removeObserver(this);
    _router?.dispose();
    _routerRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VxState(
      store: _store,
      child: MaterialApp.router(
        builder: (context, child) => AppServices(
          sounds: _sounds,
          reducedMotion: _controls.reducedMotion,
          child: child ?? const SizedBox.shrink(),
        ),
        title: 'Kids Games',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _appRouter,
      ),
    );
  }
}

class _UnknownActivityScreen extends StatelessWidget {
  const _UnknownActivityScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Game not found')),
    body: const Center(child: Text('This game is not available yet.')),
  );
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ProfileLoadErrorScreen extends StatelessWidget {
  const _ProfileLoadErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage_rounded, size: 48),
              const SizedBox(height: 16),
              const Text(
                'We could not open your saved profile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
