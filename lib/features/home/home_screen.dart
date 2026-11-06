import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_theme.dart';
import '../games/activity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverToBoxAdapter(child: _header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverToBoxAdapter(child: _hero()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text('Play & learn', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text('${starterActivities.length} games', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverGrid.builder(
                itemCount: starterActivities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.18,
                ),
                itemBuilder: (context, index) {
                  final activity = starterActivities[index];
                  final color = Color(activity.colorValue);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1025365B), blurRadius: 16, offset: Offset(0, 7)),
                      ],
                    ),
                    child: Padding(
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
                                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(0, 4)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(activity.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                          const Spacer(),
                          Text(activity.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text(activity.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.sports_esports_rounded), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.brush_rounded), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.emoji_events_rounded), label: 'Rewards'),
        ],
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset('assets/characters/fox_buddy.svg'),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, Explorer!', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w900, fontSize: 18)),
                Text('Ready for a little adventure?', style: TextStyle(color: Color(0xFF7B86A0), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_rounded, color: AppTheme.ink),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            tooltip: 'Profile',
          ),
        ],
      );

  Widget _hero() => Container(
        height: 178,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF72CFF2), Color(0xFF9B8BF0)]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Color(0x2672BFE8), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 6,
              bottom: -2,
              width: 156,
              height: 156,
              child: SvgPicture.asset('assets/illustrations/adventure_island.svg'),
            ),
            const Positioned(
              left: 20,
              top: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your next', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('BIG ADVENTURE', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text('Learn something amazing today!', style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
}
