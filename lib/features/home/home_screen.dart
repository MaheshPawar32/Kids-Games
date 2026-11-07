import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../app/store/kids_games_store.dart';
import '../../app/theme/app_theme.dart';
import '../games/activity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.childName,
    required this.grade,
    super.key,
  });

  final String childName;
  final String grade;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
    NavigationDestination(icon: Icon(Icons.sports_esports_rounded), label: 'Games'),
    NavigationDestination(icon: Icon(Icons.brush_rounded), label: 'Create'),
    NavigationDestination(icon: Icon(Icons.emoji_events_rounded), label: 'Rewards'),
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
                onProfileTap: () => _showProfile(context),
              ),
              const _FeatureLandingPage(
                title: 'Learning worlds',
                subtitle: 'Choose a world and discover something new.',
                items: [
                  _LandingItem('Alphabet & Phonics', 'Letters, sounds and first words', '🔤', 0xFFFFD36E),
                  _LandingItem('Numbers & Maths', 'Count, compare and solve', '🔢', 0xFF8FD8F4),
                  _LandingItem('Shapes & Patterns', 'Explore colors and patterns', '🔺', 0xFF9DE2C2),
                  _LandingItem('Animals & Nature', 'Meet the world around you', '🦋', 0xFFFFA98F),
                  _LandingItem('Stories & Reading', 'Listen, read and imagine', '📚', 0xFFC8B7F7),
                  _LandingItem('Science Discovery', 'Ask, explore and experiment', '🔬', 0xFF8FD8F4),
                ],
              ),
              const _GamesPage(),
              const _FeatureLandingPage(
                title: 'Creative studio',
                subtitle: 'A space for drawing, music and imagination.',
                items: [
                  _LandingItem('Drawing & Coloring', 'Make your own colorful artwork', '🎨', 0xFFFFA98F),
                  _LandingItem('Guided Drawing', 'Follow friendly step-by-step hints', '✏️', 0xFFFFD36E),
                  _LandingItem('Music & Rhythm', 'Explore sounds and simple rhythms', '🎵', 0xFFB7A8F5),
                ],
              ),
              const _RewardsPage(),
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

  void _showProfile(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Explorer profile'),
        content: Text('${childName}\\n${grade}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.childName,
    required this.grade,
    required this.onProfileTap,
  });

  final String childName;
  final String grade;
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
                  tooltip: 'Profile',
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 178,
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
              child: Stack(
                children: [
                  Positioned(
                    right: 6,
                    bottom: -2,
                    width: 156,
                    height: 156,
                    child: SvgPicture.asset(
                      'assets/illustrations/adventure_island.svg',
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    top: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'BIG ADVENTURE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Learn something amazing today!',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text('Try a game', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text('6 featured games', style: Theme.of(context).textTheme.bodyMedium),
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
                Text('Game world', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 5),
                const Text('Explore all 15 game ideas. Activities are being built in stages.'),
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
              onTap: () {
                if (activity.id == 'shape_matching') {
                  context.push<void>('/games/shape-matching');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This activity is coming in a future game update.',
                      ),
                    ),
                  );
                }
              },
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
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
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

class _FeatureLandingPage extends StatelessWidget {
  const _FeatureLandingPage({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<_LandingItem> items;

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
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 5),
                Text(subtitle),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(item.colorValue),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(item.emoji, style: const TextStyle(fontSize: 27)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF8D98AD)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LandingItem {
  const _LandingItem(this.title, this.subtitle, this.emoji, this.colorValue);

  final String title;
  final String subtitle;
  final String emoji;
  final int colorValue;
}

class _RewardsPage extends StatelessWidget {
  const _RewardsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1D4),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🏆', style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 22),
            Text(
              'Your reward shelf',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete learning activities to earn badges and fill your shelf with surprises.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
