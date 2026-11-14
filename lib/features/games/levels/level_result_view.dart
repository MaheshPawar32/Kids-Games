import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';

/// End-of-level celebration shared by every game.
class LevelResultView extends StatefulWidget {
  const LevelResultView({
    required this.level,
    required this.score,
    required this.total,
    required this.stars,
    required this.saving,
    required this.saveError,
    required this.onRetrySave,
    required this.onReplay,
    required this.onLevelMap,
    this.onNextLevel,
    this.detail,
    super.key,
  });

  final int level;
  final int score;
  final int total;
  final int stars;
  final bool saving;
  final bool saveError;
  final VoidCallback onRetrySave;
  final VoidCallback onReplay;
  final VoidCallback onLevelMap;

  /// Null when the next level is not unlocked (0 stars or final level).
  final VoidCallback? onNextLevel;

  /// Extra line such as a move count.
  final String? detail;

  @override
  State<LevelResultView> createState() => _LevelResultViewState();
}

class _LevelResultViewState extends State<LevelResultView>
    with SingleTickerProviderStateMixin {
  final List<Timer> _timers = [];
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppServices.reduceMotion(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
      for (var i = 0; i < widget.stars; i++) {
        _timers.add(
          Timer(Duration(milliseconds: 250 + i * 280), () {
            if (mounted) {
              AppServices.of(context).sounds.play(GameSound.star);
            }
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passed = widget.stars > 0;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: '${widget.stars} of 3 stars',
                excludeSemantics: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [for (var i = 0; i < 3; i++) _star(i)],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                passed ? 'Level ${widget.level} complete!' : 'Almost there!',
                key: const Key('level_result_title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'You got ${widget.score} out of ${widget.total} right.'
                    : 'You got ${widget.score} out of ${widget.total}. '
                          'Get half right to unlock the next level.',
                key: const Key('level_result_score'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: AppTheme.ink),
              ),
              if (widget.detail != null) ...[
                const SizedBox(height: 4),
                Text(widget.detail!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 8),
              Text(
                widget.saving
                    ? 'Saving your progress…'
                    : widget.saveError
                    ? 'Progress could not be saved.'
                    : 'Progress saved on this device.',
                key: const Key('session_save_status'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (widget.saveError)
                TextButton.icon(
                  onPressed: widget.onRetrySave,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry saving'),
                ),
              const SizedBox(height: 22),
              if (widget.onNextLevel != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    key: const Key('next_level_button'),
                    onPressed: widget.saving ? null : widget.onNextLevel,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      'Next level ${widget.level + 1}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  key: const Key('replay_level_button'),
                  onPressed: widget.saving ? null : widget.onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(passed ? 'Play again' : 'Try again'),
                ),
              ),
              TextButton(
                key: const Key('level_map_button'),
                onPressed: widget.onLevelMap,
                child: const Text('Level map'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _star(int index) {
    final earned = index < widget.stars;
    final start = 0.15 + index * 0.25;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        (start + 0.35).clamp(0, 1),
        curve: Curves.elasticOut,
      ),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) =>
          Transform.scale(scale: earned ? animation.value : 1, child: child),
      child: Padding(
        padding: EdgeInsets.only(
          left: 6,
          right: 6,
          bottom: index == 1 ? 18 : 0,
        ),
        child: Icon(
          Icons.star_rounded,
          size: index == 1 ? 84 : 66,
          color: earned ? const Color(0xFFFFC23D) : const Color(0xFFDCE1EC),
          shadows: earned
              ? const [Shadow(color: Color(0x55E59A00), blurRadius: 14)]
              : null,
        ),
      ),
    );
  }
}
