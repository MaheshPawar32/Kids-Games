import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

import '../features/games/shape_matching/shape_matching_game_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/child_profile.dart';
import '../features/onboarding/child_profile_repository.dart';
import '../features/onboarding/child_setup_screen.dart';
import 'store/kids_games_store.dart';
import 'theme/app_theme.dart';

class KidsGamesApp extends StatefulWidget {
  const KidsGamesApp({
    this.profileRepository,
    super.key,
  });

  final ChildProfileRepository? profileRepository;

  @override
  State<KidsGamesApp> createState() => _KidsGamesAppState();
}

class _KidsGamesAppState extends State<KidsGamesApp> {
  late final ChildProfileRepository _profileRepository =
      widget.profileRepository ?? PreferencesChildProfileRepository();
  final KidsGamesStore _store = KidsGamesStore();
  final ValueNotifier<int> _routerRefresh = ValueNotifier<int>(0);

  GoRouter? _router;
  ChildProfile? _profile;
  bool _isLoading = true;
  bool _hasLoadError = false;

  GoRouter get _appRouter => _router ??= _createRouter();

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
          builder: (context, state) => ChildSetupScreen(
            onComplete: _saveProfile,
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final profile = _profile;
            if (profile == null) {
              return const _AppLoadingScreen();
            }
            return HomeScreen(
              childName: profile.name,
              grade: profile.grade,
            );
          },
        ),
        GoRoute(
          path: '/games/shape-matching',
          builder: (context, state) => const ShapeMatchingGameScreen(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router?.dispose();
    _routerRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VxState(
      store: _store,
      child: MaterialApp.router(
        title: 'Kids Games',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _appRouter,
      ),
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
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
              FilledButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
