import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../data/repositories/game_session_repository.dart';

/// A small, fully offline Flame mini-game: children tap five glowing stars.
class FlameCountingGameScreen extends StatefulWidget {
  const FlameCountingGameScreen({
    required this.sessionRepository,
    super.key,
  });

  final GameSessionRepository sessionRepository;

  @override
  State<FlameCountingGameScreen> createState() =>
      _FlameCountingGameScreenState();
}

class _FlameCountingGameScreenState extends State<FlameCountingGameScreen> {
  late final CountingGardenGame _game =
      CountingGardenGame(onProgress: _handleProgress);
  int _collected = 0;
  bool _saving = false;
  bool _saveError = false;

  void _handleProgress(int value) {
    if (!mounted || value <= _collected) return;
    setState(() => _collected = value);
    if (value == CountingGardenGame.targetCount) {
      _game.pauseEngine();
      _saveResult();
    }
  }

  Future<void> _saveResult() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveError = false;
    });
    final completedAt = DateTime.now();
    try {
      await widget.sessionRepository.recordSession(
        GameSession(
          id: 'magic_counting_${completedAt.microsecondsSinceEpoch}',
          activityId: 'magic_counting',
          score: CountingGardenGame.targetCount,
          totalRounds: CountingGardenGame.targetCount,
          completedAt: completedAt,
        ),
      );
    } on Object {
      if (mounted) setState(() => _saveError = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _restart() {
    setState(() {
      _collected = 0;
      _saving = false;
      _saveError = false;
    });
    _game.resetRound();
    _game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _collected == CountingGardenGame.targetCount;
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Magic Counting'),
        leading: IconButton(
          tooltip: 'Back to games',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    completed
                        ? 'You found every star!'
                        : 'Find all five glowing stars',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    completed
                        ? 'Wonderful exploring!'
                        : 'Tap each star in the garden to count it.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: _collected / CountingGardenGame.targetCount,
                      minHeight: 10,
                      backgroundColor: Colors.white,
                      color: AppTheme.violet,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stars found: $_collected / ${CountingGardenGame.targetCount}',
                    key: const Key('flame_count_progress'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: GameWidget<CountingGardenGame>(
                    game: _game,
                    backgroundBuilder: (context) => const ColoredBox(
                      color: Color(0xFFEAF7FF),
                    ),
                  ),
                ),
              ),
            ),
            if (completed)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  children: [
                    Text(
                      _saving
                          ? 'Saving your progress…'
                          : _saveError
                              ? 'Progress could not be saved. Try again.'
                              : 'Progress saved on this device.',
                      key: const Key('flame_count_save_status'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : _saveError
                                ? _saveResult
                                : _restart,
                        child: Text(
                          _saveError ? 'Retry saving' : 'Play again',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CountingGardenGame extends FlameGame with TapCallbacks {
  CountingGardenGame({required this.onProgress});

  static const targetCount = 5;
  final ValueChanged<int> onProgress;
  final List<bool> _found = List<bool>.filled(targetCount, false);
  final List<ui.Offset> _normalizedPositions = const [
    ui.Offset(0.18, 0.28),
    ui.Offset(0.78, 0.22),
    ui.Offset(0.48, 0.48),
    ui.Offset(0.23, 0.76),
    ui.Offset(0.79, 0.72),
  ];
  double _elapsed = 0;

  @override
  Color backgroundColor() => const Color(0xFFEAF7FF);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
  }

  ui.Offset _centerFor(int index) {
    final normalized = _normalizedPositions[index];
    final bob = math.sin(_elapsed * 2.2 + index * 1.4) * 7;
    return ui.Offset(
      size.x * normalized.dx,
      size.y * normalized.dy + bob,
    );
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    for (var index = 0; index < targetCount; index++) {
      if (_found[index]) continue;
      final center = _centerFor(index);
      final radius = 25.0 + math.sin(_elapsed * 3 + index) * 2;
      final path = _starPath(center, radius);
      canvas.drawCircle(
        center,
        radius * 1.65,
        ui.Paint()..color = const Color(0x55FFD45F),
      );
      canvas.drawShadow(path, const Color(0x668B6B20), 8, true);
      canvas.drawPath(
        path,
        ui.Paint()
          ..shader = ui.Gradient.linear(
            center.translate(-radius, -radius),
            center.translate(radius, radius),
            const [Color(0xFFFFF3A6), Color(0xFFFFB72E)],
          ),
      );
      canvas.drawPath(
        path,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFFEF4),
      );
    }
  }

  ui.Path _starPath(ui.Offset center, double radius) {
    final path = ui.Path();
    for (var point = 0; point < 10; point++) {
      final currentRadius = point.isEven ? radius : radius * 0.46;
      final angle = -math.pi / 2 + point * math.pi / 5;
      final position = ui.Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );
      if (point == 0) {
        path.moveTo(position.dx, position.dy);
      } else {
        path.lineTo(position.dx, position.dy);
      }
    }
    return path..close();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_found.every((value) => value)) return;
    final tap = ui.Offset(event.localPosition.x, event.localPosition.y);
    for (var index = 0; index < targetCount; index++) {
      if (_found[index]) continue;
      if ((_centerFor(index) - tap).distance <= 43) {
        _found[index] = true;
        onProgress(_found.where((value) => value).length);
        return;
      }
    }
  }

  void resetRound() {
    for (var index = 0; index < _found.length; index++) {
      _found[index] = false;
    }
    _elapsed = 0;
  }
}
