import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/services/app_services.dart';
import '../../data/repositories/game_session_repository.dart';
import '../../data/repositories/level_progress_repository.dart';
import 'levels/game_level.dart';
import 'levels/level_generator.dart';
import 'levels/level_result_recorder.dart';
import 'levels/level_result_view.dart';

/// Magic Counting: a Flame mini-game. Children touch every glowing star,
/// avoid decoys and, at higher levels, say how many they counted.
class FlameCountingGameScreen extends StatefulWidget {
  const FlameCountingGameScreen({
    required this.sessionRepository,
    required this.progressRepository,
    required this.onNextLevel,
    this.level = 1,
    this.grade,
    super.key,
  });

  final GameSessionRepository sessionRepository;
  final LevelProgressRepository progressRepository;
  final ValueChanged<int> onNextLevel;
  final int level;
  final String? grade;

  @override
  State<FlameCountingGameScreen> createState() =>
      _FlameCountingGameScreenState();
}

enum _Phase { counting, askTotal, feedback, finished }

class _FlameCountingGameScreenState extends State<FlameCountingGameScreen>
    with WidgetsBindingObserver {
  late final CountingLevelSpec _spec = countingSpecFor(
    widget.level,
    grade: widget.grade,
  );
  late final LevelResultRecorder _recorder = LevelResultRecorder(
    activityId: 'magic_counting',
    level: widget.level,
    sessionRepository: widget.sessionRepository,
    progressRepository: widget.progressRepository,
  );
  late CountingGardenGame _game = _newGame();

  int _garden = 0;
  int _collected = 0;
  int _mistakes = 0;
  int _correctGardens = 0;
  int? _chosenTotal;
  List<int> _totalOptions = const [];
  _Phase _phase = _Phase.counting;
  bool _paused = false;
  bool _saving = false;
  bool _saveError = false;

  int get _stars => starsFor(_correctGardens, _spec.gardens);
  bool get _gardenCorrect =>
      _mistakes == 0 && (!_spec.askTotal || _chosenTotal == _spec.targets);

  CountingGardenGame _newGame() => CountingGardenGame(
    spec: _spec,
    seed: levelSeed('magic_counting', widget.level, _garden) ^ 0x5f3759df,
    onTargetCollected: _onTarget,
    onDecoyTapped: _onDecoy,
    // Reduced motion keeps every object still.
    reducedMotion: AppServices.reduceMotion(context),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_paused) _setPaused(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _play(GameSound sound) =>
      unawaited(AppServices.of(context).sounds.play(sound));

  void _setPaused(bool paused) {
    setState(() => _paused = paused);
    paused ? _game.pauseEngine() : _game.resumeEngine();
  }

  void _onTarget(int collected) {
    if (!mounted) return;
    setState(() => _collected = collected);
    _play(GameSound.tap);
    if (collected == _spec.targets) {
      if (_spec.askTotal) {
        final r = math.Random(_garden + widget.level);
        final options = <int>{_spec.targets};
        while (options.length < 4) {
          final delta = r.nextInt(5) - 2;
          if (_spec.targets + delta > 0) options.add(_spec.targets + delta);
        }
        setState(() {
          _totalOptions = options.toList()..sort();
          _phase = _Phase.askTotal;
        });
      } else {
        _endGarden();
      }
    }
  }

  void _onDecoy() {
    if (!mounted) return;
    setState(() => _mistakes++);
    _play(GameSound.wrong);
  }

  void _chooseTotal(int value) {
    if (_phase != _Phase.askTotal) return;
    setState(() => _chosenTotal = value);
    _endGarden();
  }

  void _endGarden() {
    final correct = _gardenCorrect;
    setState(() {
      if (correct) _correctGardens++;
      _phase = _Phase.feedback;
    });
    _play(correct ? GameSound.correct : GameSound.wrong);
  }

  Future<void> _nextGarden() async {
    if (_garden == _spec.gardens - 1) {
      setState(() => _phase = _Phase.finished);
      _play(_stars > 0 ? GameSound.levelComplete : GameSound.wrong);
      await _save();
      return;
    }
    setState(() {
      _garden++;
      _collected = 0;
      _mistakes = 0;
      _chosenTotal = null;
      _phase = _Phase.counting;
      _game = _newGame();
    });
  }

  Future<void> _save() async {
    if (_saving || _recorder.saved) return;
    setState(() {
      _saving = true;
      _saveError = false;
    });
    try {
      await _recorder.save(
        score: _correctGardens,
        total: _spec.gardens,
        stars: _stars,
      );
    } on Object {
      if (mounted) setState(() => _saveError = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text('Magic Counting · Level ${widget.level}'),
        actions: [
          if (_phase != _Phase.finished)
            IconButton(
              tooltip: _paused ? 'Resume game' : 'Pause game',
              onPressed: () => _setPaused(!_paused),
              icon: Icon(
                _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _phase == _Phase.finished
            ? LevelResultView(
                level: widget.level,
                score: _correctGardens,
                total: _spec.gardens,
                stars: _stars,
                saving: _saving,
                saveError: _saveError,
                onRetrySave: _save,
                onReplay: () => widget.onNextLevel(widget.level),
                onNextLevel: _stars > 0 && widget.level < kLevelsPerGame
                    ? () => widget.onNextLevel(widget.level + 1)
                    : null,
                onLevelMap: () => Navigator.of(context).maybePop(),
              )
            : _playView(),
      ),
    );
  }

  Widget _playView() {
    final counterText = _spec.askTotal
        ? 'Stars found: ?'
        : 'Stars found: $_collected / ${_spec.targets}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            children: [
              Text(
                _spec.decoys > 0
                    ? 'Touch every star — not the moons or flowers!'
                    : 'Touch every glowing star to count it',
                key: const Key('flame_count_instruction'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Garden ${_garden + 1}/${_spec.gardens}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    counterText,
                    key: const Key('flame_count_progress'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Semantics(
                    label: 'Counting garden. ${_spec.targets} stars to find.',
                    child: GameWidget<CountingGardenGame>(
                      key: ValueKey(_garden),
                      game: _game,
                    ),
                  ),
                  if (_paused) _overlay(_pauseCard()),
                  if (!_paused && _phase == _Phase.askTotal)
                    _overlay(_askTotalCard()),
                  if (!_paused && _phase == _Phase.feedback)
                    _overlay(_feedbackCard()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _overlay(Widget child) => ColoredBox(
    color: const Color(0x99FFFFFF),
    child: Center(
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      boxShadow: const [BoxShadow(color: Color(0x2225365B), blurRadius: 20)],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );

  Widget _pauseCard() => _card([
    const Text('⏸️', style: TextStyle(fontSize: 48)),
    const SizedBox(height: 8),
    const Text(
      'Take a little break',
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
    ),
    const SizedBox(height: 12),
    FilledButton.icon(
      key: const Key('resume_button'),
      onPressed: () => _setPaused(false),
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Resume'),
    ),
  ]);

  Widget _askTotalCard() => _card([
    const Text(
      'How many stars did you count?',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
    ),
    const SizedBox(height: 14),
    Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final value in _totalOptions)
          SizedBox(
            width: 72,
            height: 64,
            child: FilledButton.tonal(
              key: Key('total_$value'),
              onPressed: () => _chooseTotal(value),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    ),
  ]);

  Widget _feedbackCard() {
    final correct = _gardenCorrect;
    final reason = _mistakes > 0
        ? 'Only stars count — you touched $_mistakes '
              '${_mistakes == 1 ? 'decoy' : 'decoys'}.'
        : _spec.askTotal && _chosenTotal != _spec.targets
        ? 'There were ${_spec.targets} stars.'
        : 'You counted all ${_spec.targets} stars!';
    return _card([
      Text(correct ? '🌟' : '💛', style: const TextStyle(fontSize: 48)),
      Text(
        correct ? 'Wonderful counting!' : 'Good try!',
        key: const Key('flame_count_feedback'),
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
      ),
      const SizedBox(height: 6),
      Text(reason, textAlign: TextAlign.center),
      const SizedBox(height: 14),
      FilledButton.icon(
        key: const Key('next_garden_button'),
        onPressed: _nextGarden,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          _garden == _spec.gardens - 1 ? 'See my stars' : 'Next garden',
        ),
      ),
    ]);
  }
}

/// Flame world for one counting garden.
class CountingGardenGame extends FlameGame {
  CountingGardenGame({
    required this.spec,
    required this.seed,
    required this.onTargetCollected,
    required this.onDecoyTapped,
    this.reducedMotion = false,
  });

  final CountingLevelSpec spec;
  final int seed;
  final ValueChanged<int> onTargetCollected;
  final VoidCallback onDecoyTapped;
  final bool reducedMotion;
  int _collected = 0;

  final List<CountingTarget> targets = [];
  final List<CountingDecoy> decoys = [];

  int get collected => _collected;

  @override
  Color backgroundColor() => const Color(0xFFEAF7FF);

  @override
  Future<void> onLoad() async {
    final random = math.Random(seed);
    add(_GardenBackground());
    final placed = <Vector2>[];
    Vector2 spot() {
      const margin = 44.0;
      for (var attempt = 0; attempt < 200; attempt++) {
        final candidate = Vector2(
          margin + random.nextDouble() * math.max(1, size.x - margin * 2),
          margin + random.nextDouble() * math.max(1, size.y - margin * 2),
        );
        if (placed.every((p) => p.distanceTo(candidate) > 70)) {
          placed.add(candidate);
          return candidate;
        }
      }
      final fallback = Vector2(
        margin + random.nextDouble() * math.max(1, size.x - margin * 2),
        margin + random.nextDouble() * math.max(1, size.y - margin * 2),
      );
      placed.add(fallback);
      return fallback;
    }

    Vector2 velocity() {
      if (spec.speed <= 0 || reducedMotion) return Vector2.zero();
      final angle = random.nextDouble() * math.pi * 2;
      return Vector2(math.cos(angle), math.sin(angle)) * spec.speed;
    }

    for (var i = 0; i < spec.targets; i++) {
      final target = CountingTarget(
        position: spot(),
        velocity: velocity(),
        phase: random.nextDouble() * 6,
        onCollected: _collect,
      );
      targets.add(target);
      add(target);
    }
    for (var i = 0; i < spec.decoys; i++) {
      final decoy = CountingDecoy(
        position: spot(),
        velocity: velocity(),
        kind: i.isEven ? DecoyKind.moon : DecoyKind.flower,
        onTapped: onDecoyTapped,
      );
      decoys.add(decoy);
      add(decoy);
    }
  }

  void _collect(CountingTarget target) {
    _collected++;
    add(
      ParticleSystemComponent(
        position: target.position.clone(),
        particle: Particle.generate(
          count: 14,
          lifespan: 0.6,
          generator: (i) {
            final angle = i / 14 * math.pi * 2;
            return AcceleratedParticle(
              speed: Vector2(math.cos(angle), math.sin(angle)) * 120,
              acceleration: Vector2(0, 160),
              child: CircleParticle(
                radius: 3.2,
                paint: Paint()..color = const Color(0xFFFFC94F),
              ),
            );
          },
        ),
      ),
    );
    onTargetCollected(_collected);
  }
}

class _GardenBackground extends Component with HasGameReference<FlameGame> {
  @override
  int get priority => -1;

  @override
  void render(ui.Canvas canvas) {
    final size = game.size;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDF1FF), Color(0xFFEAF9E8)],
        ).createShader(rect),
    );
    final hill = Paint()..color = const Color(0xFFBFE8C4);
    canvas.drawOval(
      Rect.fromLTWH(-size.x * 0.2, size.y * 0.78, size.x * 0.9, size.y * 0.5),
      hill,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.4, size.y * 0.82, size.x * 0.9, size.y * 0.5),
      hill..color = const Color(0xFFA9DEB1),
    );
  }
}

/// Moves with a gentle drift and bounces inside the garden.
mixin _Drifting on PositionComponent, HasGameReference<FlameGame> {
  late Vector2 velocity;

  void drift(double dt) {
    if (velocity.isZero()) return;
    position += velocity * dt;
    const margin = 30.0;
    if (position.x < margin || position.x > game.size.x - margin) {
      velocity.x = -velocity.x;
      position.x = position.x.clamp(margin, game.size.x - margin);
    }
    if (position.y < margin || position.y > game.size.y - margin) {
      velocity.y = -velocity.y;
      position.y = position.y.clamp(margin, game.size.y - margin);
    }
  }
}

class CountingTarget extends PositionComponent
    with TapCallbacks, HasGameReference<FlameGame>, _Drifting {
  CountingTarget({
    required super.position,
    required Vector2 velocity,
    required this.phase,
    required this.onCollected,
  }) : super(size: Vector2.all(64), anchor: Anchor.center) {
    this.velocity = velocity;
  }

  final double phase;
  final void Function(CountingTarget) onCollected;
  double _time = 0;
  bool collected = false;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    drift(dt);
  }

  /// Generous hit area (64 px) for small fingers.
  @override
  bool containsLocalPoint(Vector2 point) =>
      point.distanceTo(size / 2) <= size.x * 0.62;

  @override
  void onTapDown(TapDownEvent event) {
    if (collected) return;
    collected = true;
    onCollected(this);
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.4), EffectController(duration: 0.12)),
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.18)),
        RemoveEffect(),
      ]),
    );
  }

  @override
  void render(ui.Canvas canvas) {
    final center = (size / 2).toOffset();
    final radius = 24 + math.sin(_time * 3 + phase) * 2;
    canvas.drawCircle(
      center,
      radius * 1.6,
      Paint()..color = const Color(0x44FFD45F),
    );
    final path = _starPath(center, radius);
    canvas.drawShadow(path, const Color(0x668B6B20), 6, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          center.translate(-radius, -radius),
          center.translate(radius, radius),
          const [Color(0xFFFFF3A6), Color(0xFFFFB72E)],
        ),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFFEF4),
    );
  }
}

enum DecoyKind { moon, flower }

class CountingDecoy extends PositionComponent
    with TapCallbacks, HasGameReference<FlameGame>, _Drifting {
  CountingDecoy({
    required super.position,
    required Vector2 velocity,
    required this.kind,
    required this.onTapped,
  }) : super(size: Vector2.all(58), anchor: Anchor.center) {
    this.velocity = velocity;
  }

  final DecoyKind kind;
  final VoidCallback onTapped;
  bool _shaking = false;

  @override
  void update(double dt) {
    super.update(dt);
    drift(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped();
    if (_shaking) return;
    _shaking = true;
    add(
      SequenceEffect([
        RotateEffect.by(0.25, EffectController(duration: 0.06)),
        RotateEffect.by(-0.5, EffectController(duration: 0.12)),
        RotateEffect.by(0.25, EffectController(duration: 0.06)),
      ], onComplete: () => _shaking = false),
    );
  }

  @override
  void render(ui.Canvas canvas) {
    final c = (size / 2).toOffset();
    if (kind == DecoyKind.moon) {
      final moon = Path()
        ..addOval(Rect.fromCircle(center: c, radius: 22))
        ..fillType = PathFillType.evenOdd;
      final bite = Path()
        ..addOval(Rect.fromCircle(center: c.translate(10, -6), radius: 19));
      canvas.drawPath(
        Path.combine(PathOperation.difference, moon, bite),
        Paint()..color = const Color(0xFF9FB4E8),
      );
    } else {
      final petal = Paint()..color = const Color(0xFFF49AC1);
      for (var i = 0; i < 5; i++) {
        final angle = i * math.pi * 2 / 5;
        canvas.drawCircle(
          c + Offset(math.cos(angle), math.sin(angle)) * 12,
          10,
          petal,
        );
      }
      canvas.drawCircle(c, 8, Paint()..color = const Color(0xFFFFE07A));
    }
  }
}

ui.Path _starPath(ui.Offset center, double radius) {
  final path = ui.Path();
  for (var point = 0; point < 10; point++) {
    final r = point.isEven ? radius : radius * 0.46;
    final angle = -math.pi / 2 + point * math.pi / 5;
    final position = ui.Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );
    point == 0
        ? path.moveTo(position.dx, position.dy)
        : path.lineTo(position.dx, position.dy);
  }
  return path..close();
}
