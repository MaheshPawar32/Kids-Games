import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../app/store/kids_games_store.dart';
import '../../app/theme/app_theme.dart';
import '../../core/assets/kids_games_3d_assets.dart';
import '../../core/widgets/three_d_asset_preview.dart';
import '../games/activity.dart';
import '../../data/repositories/game_session_repository.dart';
import '../../data/repositories/level_progress_repository.dart';
import '../learn/learn_worlds_screen.dart';
import '../create/create_studio_screen.dart';
import 'today_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.childName,
    required this.grade,
    required this.gameSessionRepository,
    required this.levelProgressRepository,
    super.key,
  });

  final String childName;
  final String grade;
  final GameSessionRepository gameSessionRepository;
  final LevelProgressRepository levelProgressRepository;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
    NavigationDestination(
      icon: Icon(Icons.sports_esports_rounded),
      label: 'Games',
    ),
    NavigationDestination(icon: Icon(Icons.brush_rounded), label: 'Create'),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_rounded),
      label: 'Rewards',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return VxBuilder<KidsGamesStore>(
      mutations: const {SelectHomeTab},
      builder: (context, store, status) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: store.selectedTabIndex,
            children: [
              _HomeDashboard(
                childName: childName,
                grade: grade,
                gameSessionRepository: gameSessionRepository,
                levelProgressRepository: levelProgressRepository,
                onProfileTap: () => context.push<void>('/parent-gate'),
              ),
              const LearnWorldsScreen(),
              const _GamesPage(),
              const CreateStudioScreen(),
              _RewardsPage(gameSessionRepository: gameSessionRepository),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: store.selectedTabIndex,
          onDestinationSelected: (index) {
            SelectHomeTab(index);
          },
          destinations: _destinations,
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.childName,
    required this.grade,
    required this.gameSessionRepository,
    required this.levelProgressRepository,
    required this.onProfileTap,
  });

  final String childName;
  final String grade;
  final GameSessionRepository gameSessionRepository;
  final LevelProgressRepository levelProgressRepository;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    'assets/characters/fox_buddy.svg',
                    semanticsLabel: 'Fox buddy',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $childName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '$grade explorer',
                        style: const TextStyle(
                          color: Color(0xFF7B86A0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onProfileTap,
                  icon: const Icon(Icons.person_rounded, color: AppTheme.ink),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  tooltip: 'Parent area',
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: TodayPanel(
              sessionRepository: gameSessionRepository,
              progressRepository: levelProgressRepository,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Try a game',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  '6 featured games',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        _ActivityGrid(activities: starterActivities.take(6).toList()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1D4),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Text('⭐', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Every little step is a big achievement. Keep exploring!',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GamesPage extends StatelessWidget {
  const _GamesPage();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game world',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Explore all 15 offline learning activities. Pick a challenge and learn by playing.',
                ),
              ],
            ),
          ),
        ),
        const _ActivityGrid(activities: starterActivities),
      ],
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      sliver: SliverGrid.builder(
        itemCount: activities.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.18,
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          final color = Color(activity.colorValue);
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: Key('activity_${activity.id}'),
              onTap: () => context.push<void>('/games/${activity.id}'),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1025365B),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        activity.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activity.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RewardsPage extends StatelessWidget {
  const _RewardsPage({required this.gameSessionRepository});

  final GameSessionRepository gameSessionRepository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: gameSessionRepository.revision,
      builder: (context, revision, child) {
        return FutureBuilder<List<GameSession>>(
          future: gameSessionRepository.recentSessions(limit: 100),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Your progress could not be loaded.'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProgress(context, snapshot.data ?? const []);
          },
        );
      },
    );
  }

  Widget _buildProgress(BuildContext context, List<GameSession> sessions) {
    final totalCorrect = sessions.fold<int>(0, (sum, item) => sum + item.score);
    final totalQuestions = sessions.fold<int>(
      0,
      (sum, item) => sum + item.totalRounds,
    );
    final perfectGames = sessions
        .where((item) => item.totalRounds > 0 && item.score == item.totalRounds)
        .length;
    final accuracy = totalQuestions == 0
        ? 0
        : (totalCorrect / totalQuestions * 100).round();

    final badges = <_ProgressBadge>[
      _ProgressBadge(
        'First Steps',
        'Finish your first game',
        '🌱',
        sessions.isNotEmpty,
      ),
      _ProgressBadge(
        'Bright Spark',
        'Finish five games',
        '✨',
        sessions.length >= 5,
      ),
      _ProgressBadge(
        'Learning Star',
        'Finish fifteen games',
        '⭐',
        sessions.length >= 15,
      ),
      _ProgressBadge(
        'Perfect Player',
        'Get every answer right',
        '🏆',
        perfectGames > 0,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your progress & rewards',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text('Every completed game is saved on this device.'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ProgressStat(
                  value: '${sessions.length}',
                  label: 'Games played',
                  emoji: '🎮',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressStat(
                  value: '$accuracy%',
                  label: 'Accuracy',
                  emoji: '🎯',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressStat(
                  value: '$perfectGames',
                  label: 'Perfect games',
                  emoji: '🏆',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Badge shelf', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final badge in badges) ...[
            _BadgeTile(badge: badge),
            const SizedBox(height: 9),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent games',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                '${sessions.length} saved',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (sessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('🧸', style: TextStyle(fontSize: 42)),
                  SizedBox(height: 8),
                  Text(
                    'Your adventure starts here',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Play a game and your score will appear on this shelf.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            for (final session in sessions.take(8))
              _SessionTile(session: session),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const _ThreeDIconGalleryDialog(),
            ),
            icon: const Icon(Icons.view_in_ar_rounded),
            label: const Text('Explore the 3D asset gallery'),
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.value,
    required this.label,
    required this.emoji,
  });

  final String value;
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF71809B)),
          ),
        ],
      ),
    );
  }
}

class _ProgressBadge {
  const _ProgressBadge(this.title, this.description, this.emoji, this.unlocked);

  final String title;
  final String description;
  final String emoji;
  final bool unlocked;
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final _ProgressBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge.unlocked
              ? const Color(0xFFFFD36E)
              : const Color(0xFFE7EAF2),
        ),
      ),
      child: Row(
        children: [
          Text(
            badge.unlocked ? badge.emoji : '🔒',
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  badge.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (badge.unlocked)
            const Icon(Icons.check_circle_rounded, color: Colors.green),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final activity = starterActivities.firstWhere(
      (item) => item.id == session.activityId,
      orElse: () => Activity(
        id: session.activityId,
        title: session.activityId,
        description: '',
        emoji: '🎮',
        colorValue: 0xFFEAEAF2,
      ),
    );
    final date = session.completedAt.toLocal();
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(activity.colorValue),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(activity.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${session.score}/${session.totalRounds}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ThreeDIconGalleryDialog extends StatefulWidget {
  const _ThreeDIconGalleryDialog();

  @override
  State<_ThreeDIconGalleryDialog> createState() =>
      _ThreeDIconGalleryDialogState();
}

class _ThreeDIconGalleryDialogState extends State<_ThreeDIconGalleryDialog> {
  static const _groups = <String, Map<String, String>>{
    'Icons': KidsGames3DAssets.icons,
    'Numbers': KidsGames3DAssets.numbers,
    'Alphabet': KidsGames3DAssets.letters,
    'Shapes': KidsGames3DAssets.shapes,
    'Props': KidsGames3DAssets.props,
    'Environments': KidsGames3DAssets.environments,
  };

  String _selectedGroup = 'Icons';
  String _selectedAsset = 'trophy';

  Map<String, String> get _assets => _groups[_selectedGroup]!;

  String _labelFor(String id) {
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final selectedPath = _assets[_selectedAsset]!;

    return AlertDialog(
      title: const Text('3D learning asset gallery'),
      content: SizedBox(
        width: 360,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedGroup,
              decoration: const InputDecoration(
                labelText: 'Asset collection',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final group in _groups.keys)
                  DropdownMenuItem(value: group, child: Text(group)),
              ],
              onChanged: (group) {
                if (group == null) return;
                setState(() {
                  _selectedGroup = group;
                  _selectedAsset = _groups[group]!.keys.first;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ColoredBox(
                  color: const Color(0xFFF4F6FB),
                  child: ThreeDAssetPreview(
                    key: ValueKey(selectedPath),
                    assetPath: selectedPath,
                    scale: 1.0,
                    semanticsLabel: '3D ${_labelFor(_selectedAsset)} preview',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_labelFor(_selectedAsset)} · ${_assets.length} assets in this collection',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    for (final assetId in _assets.keys)
                      ChoiceChip(
                        label: Text(_labelFor(assetId)),
                        selected: assetId == _selectedAsset,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedAsset = assetId);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
