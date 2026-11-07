import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/child_profile.dart';
import '../features/onboarding/child_profile_repository.dart';
import '../features/onboarding/child_setup_screen.dart';
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

  ChildProfile? _profile;
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });
    try {
      final profile = await _profileRepository.loadProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLoadError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile(ChildProfile profile) async {
    await _profileRepository.saveProfile(profile);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _buildEntryScreen(),
    );
  }

  Widget _buildEntryScreen() {
    if (_isLoading) return const _AppLoadingScreen();
    if (_hasLoadError) {
      return _ProfileLoadErrorScreen(onRetry: _loadProfile);
    }
    final profile = _profile;
    if (profile == null) {
      return ChildSetupScreen(onComplete: _saveProfile);
    }
    return HomeScreen(childName: profile.name, grade: profile.grade);
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
