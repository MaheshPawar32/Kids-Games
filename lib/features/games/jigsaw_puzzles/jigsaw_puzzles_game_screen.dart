import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../data/repositories/game_session_repository.dart';
import '../../../data/repositories/level_progress_repository.dart';
import '../levels/game_level.dart';
import '../levels/level_generator.dart';
import '../levels/level_result_recorder.dart';
import '../levels/level_result_view.dart';

/// Jigsaw Puzzles: a Flame game with real interlocking pieces cut from a
/// generated picture. Pieces snap into place; tap-then-tap also works.
class JigsawPuzzlesGameScreen extends StatefulWidget {
  const JigsawPuzzlesGameScreen({
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
  State<JigsawPuzzlesGameScreen> createState() =>
      _JigsawPuzzlesGameScreenState();
}

class _JigsawPuzzlesGameScreenState extends State<JigsawPuzzlesGameScreen>
    with WidgetsBindingObserver {
  late final JigsawLevelSpec _spec = jigsawSpecFor(
    widget.level,
    grade: widget.grade,
  );
  late final LevelResultRecorder _recorder = LevelResultRecorder(
    activityId: 'jigsaw_puzzles',
    level: widget.level,
    sessionRepository: widget.sessionRepository,
    progressRepository: widget.progressRepository,
  );
  late final JigsawGame _game = JigsawGame(
    spec: _spec,
    onMove: _onMove,
    onPlaced: _onPlaced,
    onComplete: _onComplete,
  );

  int _moves = 0;
  int _placed = 0;
  bool _finished = false;
  bool _paused = false;
  bool _saving = false;
  bool _saveError = false;

  int get _stars => _spec.starsForMoves(_moves);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_paused && !_finished) {
      _setPaused(true);
    }
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

  void _onMove(bool placed) {
    if (!mounted) return;
    setState(() => _moves++);
    if (!placed) _play(GameSound.wrong);
  }

  void _onPlaced(int placed) {
    if (!mounted) return;
    setState(() => _placed = placed);
    _play(GameSound.correct);
  }

  Future<void> _onComplete() async {
    if (!mounted || _finished) return;
    setState(() => _finished = true);
    _play(GameSound.levelComplete);
    await _save();
  }

  Future<void> _save() async {
    if (_saving || _recorder.saved) return;
    setState(() {
      _saving = true;
      _saveError = false;
    });
    try {
      // Accuracy = pieces / moves, so efficient solving scores higher.
      await _recorder.save(
        score: _spec.pieces,
        total: math.max(_spec.pieces, _moves),
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
        title: Text('Jigsaw · Level ${widget.level}'),
        actions: [
          if (!_finished)
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
        child: _finished
            ? LevelResultView(
                level: widget.level,
                score: _spec.pieces,
                total: _spec.pieces,
                stars: _stars,
                detail:
                    'Solved in $_moves moves '
                    '(${_spec.pieces} is perfect).',
                saving: _saving,
                saveError: _saveError,
                onRetrySave: _save,
                onReplay: () => widget.onNextLevel(widget.level),
                onNextLevel: widget.level < kLevelsPerGame
                    ? () => widget.onNextLevel(widget.level + 1)
                    : null,
                onLevelMap: () => Navigator.of(context).maybePop(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Drag each piece into the picture. '
                            'Or tap a piece, then tap its spot.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_placed/${_spec.pieces} · $_moves moves',
                          key: const Key('jigsaw_progress'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Semantics(
                              label:
                                  'Jigsaw puzzle with ${_spec.pieces} '
                                  'pieces. $_placed placed.',
                              child: GameWidget<JigsawGame>(game: _game),
                            ),
                            if (_paused)
                              ColoredBox(
                                color: const Color(0xCCFFFFFF),
                                child: Center(
                                  child: FilledButton.icon(
                                    key: const Key('resume_button'),
                                    onPressed: () => _setPaused(false),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('Resume'),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Picture themes painted for each level.
class _Theme {
  const _Theme(this.sky, this.ground, this.items, {this.night = false});

  final List<Color> sky;
  final Color ground;
  final List<String> items;
  final bool night;
}

const _themes = [
  _Theme(
    [Color(0xFF8FD3FF), Color(0xFFE3F5FF)],
    Color(0xFF8BD17C),
    ['🐄', '🐷', '🐔', '🚜', '🌻', '🐑', '🏡'],
  ),
  _Theme(
    [Color(0xFF4FC3F7), Color(0xFFB3E5FC)],
    Color(0xFF29B6F6),
    ['🐳', '🐠', '🐙', '⛵', '🦀', '🐬', '🐢'],
  ),
  _Theme(
    [Color(0xFF1A237E), Color(0xFF5C6BC0)],
    Color(0xFF3949AB),
    ['🚀', '🌍', '⭐', '🌙', '👽', '☄️', '🛸'],
    night: true,
  ),
  _Theme(
    [Color(0xFFFFE0B2), Color(0xFFFFF8E1)],
    Color(0xFFA5D6A7),
    ['🌷', '🦋', '🐝', '🍄', '🐞', '🌼', '🐌'],
  ),
  _Theme(
    [Color(0xFF81D4FA), Color(0xFFFFF9C4)],
    Color(0xFFFFE082),
    ['🏖️', '🌴', '🦀', '⛱️', '🐚', '🍦', '🏰'],
  ),
  _Theme(
    [Color(0xFFA5D6A7), Color(0xFFE8F5E9)],
    Color(0xFF66BB6A),
    ['🦁', '🐘', '🦒', '🐒', '🌴', '🦜', '🐯'],
  ),
];

/// Paints the level's picture at [width]×[height] logical px.
Future<ui.Image> paintJigsawScene(
  int seed,
  double width,
  double height,
  double pixelRatio,
) async {
  final random = math.Random(seed);
  final theme = _themes[random.nextInt(_themes.length)];
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  final rect = Rect.fromLTWH(0, 0, width, height);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: theme.sky,
      ).createShader(rect),
  );
  // Sun or moon.
  canvas.drawCircle(
    Offset(width * (0.15 + random.nextDouble() * 0.7), height * 0.18),
    math.min(width, height) * 0.1,
    Paint()
      ..color = theme.night ? const Color(0xFFFFF59D) : const Color(0xFFFFD54F),
  );
  // Rolling ground.
  final ground = Path()..moveTo(0, height * 0.66);
  for (var x = 0.0; x <= width; x += width / 8) {
    ground.lineTo(
      x,
      height * (0.62 + math.sin(x / width * math.pi * 2 + seed) * 0.05),
    );
  }
  ground
    ..lineTo(width, height)
    ..lineTo(0, height)
    ..close();
  canvas.drawPath(ground, Paint()..color = theme.ground);
  // Picture items spread over a 3×3 grid so every piece shows something.
  final cells = List<int>.generate(9, (i) => i)..shuffle(random);
  final items = [...theme.items]..shuffle(random);
  for (var i = 0; i < 7; i++) {
    final cell = cells[i];
    final cx = (cell % 3 + 0.2 + random.nextDouble() * 0.6) / 3 * width;
    final cy = (cell ~/ 3 + 0.2 + random.nextDouble() * 0.6) / 3 * height;
    final fontSize =
        math.min(width, height) * (0.14 + random.nextDouble() * 0.08);
    final painter = TextPainter(
      text: TextSpan(
        text: items[i],
        style: TextStyle(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(cx - painter.width / 2, cy - painter.height / 2),
    );
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (width * pixelRatio).round(),
    (height * pixelRatio).round(),
  );
  picture.dispose();
  return image;
}

class JigsawGame extends FlameGame {
  JigsawGame({
    required this.spec,
    required this.onMove,
    required this.onPlaced,
    required this.onComplete,
  });

  final JigsawLevelSpec spec;
  final ValueChanged<bool> onMove;
  final ValueChanged<int> onPlaced;
  final Future<void> Function() onComplete;

  static const _pixelRatio = 2.0;
  late double cell;
  late Vector2 boardOrigin;
  ui.Image? _image;
  final List<JigsawPiece> pieces = [];
  JigsawPiece? selected;
  int placedCount = 0;

  @override
  Color backgroundColor() => const Color(0xFFF1F5FC);

  @override
  Future<void> onLoad() async {
    cell = _cellSize();
    final boardSize = Vector2(cell * spec.columns, cell * spec.rows);
    boardOrigin = Vector2((size.x - boardSize.x) / 2, 12);
    final image = await paintJigsawScene(
      spec.sceneSeed,
      boardSize.x,
      boardSize.y,
      _pixelRatio,
    );
    _image = image;
    add(
      JigsawBoard(
        position: boardOrigin,
        size: boardSize,
        image: image,
        pixelRatio: _pixelRatio,
        showGuide: spec.showGuide,
      ),
    );

    final random = math.Random(spec.sceneSeed);
    final tab = cell * 0.22;
    // Each internal edge gets one tab direction shared by both neighbours.
    final right = [
      for (var r = 0; r < spec.rows; r++)
        [for (var c = 0; c < spec.columns; c++) random.nextBool() ? 1 : -1],
    ];
    final bottom = [
      for (var r = 0; r < spec.rows; r++)
        [for (var c = 0; c < spec.columns; c++) random.nextBool() ? 1 : -1],
    ];
    final trayTop = boardOrigin.y + boardSize.y + 16;
    final pieceSize = cell + tab * 2;
    // Lay pieces out in a shuffled tray grid when they fit; the largest
    // puzzles become a pile, like a real jigsaw.
    final trayColumns = math.max(1, (size.x / (pieceSize + 4)).floor());
    final trayRows = math.max(
      1,
      ((size.y - trayTop) / (pieceSize + 4)).floor(),
    );
    final slots = List<int>.generate(trayColumns * trayRows, (i) => i)
      ..shuffle(random);
    final useSlots = slots.length >= spec.pieces;
    final slotGapX = (size.x - trayColumns * pieceSize) / (trayColumns + 1);
    final slotGapY = (size.y - trayTop - trayRows * pieceSize) / (trayRows + 1);
    var slotIndex = 0;
    for (var r = 0; r < spec.rows; r++) {
      for (var c = 0; c < spec.columns; c++) {
        final edges = (
          top: r == 0 ? 0 : -bottom[r - 1][c],
          right: c == spec.columns - 1 ? 0 : right[r][c],
          bottom: r == spec.rows - 1 ? 0 : bottom[r][c],
          left: c == 0 ? 0 : -right[r][c - 1],
        );
        final home = boardOrigin + Vector2(c * cell - tab, r * cell - tab);
        final Vector2 start;
        if (useSlots) {
          final slot = slots[slotIndex++];
          start = Vector2(
            slotGapX + (slot % trayColumns) * (pieceSize + slotGapX),
            trayTop + slotGapY + (slot ~/ trayColumns) * (pieceSize + slotGapY),
          );
        } else {
          start = Vector2(
            random.nextDouble() * math.max(1, size.x - pieceSize),
            trayTop +
                random.nextDouble() * math.max(1, size.y - trayTop - pieceSize),
          );
        }
        final piece = JigsawPiece(
          row: r,
          column: c,
          cell: cell,
          tab: tab,
          edges: edges,
          image: image,
          pixelRatio: _pixelRatio,
          home: home,
          position: start,
        );
        pieces.add(piece);
        add(piece);
      }
    }
  }

  /// Largest cell size (40–150 px) that leaves every piece its own tray
  /// slot below the board; very large puzzles fall back to a pile.
  double _cellSize() {
    var candidate = math.min(
      math.min((size.x - 24) / spec.columns, size.y * 0.6 / spec.rows),
      150.0,
    );
    while (candidate > 40) {
      final slot = candidate * 1.44 + 4;
      final trayTop = 12 + candidate * spec.rows + 16;
      final fits =
          (size.x / slot).floor() * ((size.y - trayTop) / slot).floor();
      if (fits >= spec.pieces) return candidate;
      candidate -= 2;
    }
    return math.max(candidate, 40);
  }

  @override
  void onRemove() {
    _image?.dispose();
    super.onRemove();
  }

  void select(JigsawPiece piece) {
    selected?.selected = false;
    selected = piece == selected ? null : piece;
    selected?.selected = true;
  }

  /// Called after a drag ends; snaps when close to the home position.
  void dropped(JigsawPiece piece) {
    final close = piece.position.distanceTo(piece.home) < cell * 0.35;
    onMove(close);
    if (close) _place(piece);
  }

  /// Tap-to-place alternative: [row]/[column] is the tapped board cell.
  void tappedCell(int row, int column) {
    final piece = selected;
    if (piece == null || piece.placed) return;
    final correct = piece.row == row && piece.column == column;
    onMove(correct);
    if (correct) {
      _place(piece);
    } else {
      piece.shake();
    }
  }

  void _place(JigsawPiece piece) {
    piece
      ..placed = true
      ..selected = false
      ..priority = 1;
    if (selected == piece) selected = null;
    piece.add(MoveEffect.to(piece.home, EffectController(duration: 0.12)));
    placedCount++;
    onPlaced(placedCount);
    if (placedCount == pieces.length) {
      _celebrate();
      Future<void>.delayed(const Duration(milliseconds: 900), onComplete);
    }
  }

  void _celebrate() {
    final random = math.Random();
    const colors = [
      Color(0xFFFFC94F),
      Color(0xFF59B9EF),
      Color(0xFFF06292),
      Color(0xFF66C99B),
      Color(0xFF967CEB),
    ];
    add(
      ParticleSystemComponent(
        position: Vector2(size.x / 2, size.y * 0.3),
        particle: Particle.generate(
          count: 60,
          lifespan: 1.2,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              (random.nextDouble() - 0.5) * 520,
              -200 - random.nextDouble() * 260,
            ),
            acceleration: Vector2(0, 520),
            child: CircleParticle(
              radius: 3 + random.nextDouble() * 3,
              paint: Paint()..color = colors[i % colors.length],
            ),
          ),
        ),
      ),
    );
  }
}

class JigsawBoard extends PositionComponent
    with TapCallbacks, HasGameReference<JigsawGame> {
  JigsawBoard({
    required super.position,
    required super.size,
    required this.image,
    required this.pixelRatio,
    required this.showGuide,
  }) : super(priority: 0);

  final ui.Image image;
  final double pixelRatio;
  final bool showGuide;

  @override
  void onTapUp(TapUpEvent event) {
    final cell = game.cell;
    final column = (event.localPosition.x / cell).floor();
    final row = (event.localPosition.y / cell).floor();
    game.tappedCell(row, column);
  }

  @override
  void render(ui.Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(6), const Radius.circular(14)),
      Paint()..color = Colors.white,
    );
    if (showGuide) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        rect,
        Paint()..color = const Color(0x33000000),
      );
    }
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFD5DCEA);
    final cell = game.cell;
    for (var c = 0; c <= game.spec.columns; c++) {
      canvas.drawLine(Offset(c * cell, 0), Offset(c * cell, size.y), grid);
    }
    for (var r = 0; r <= game.spec.rows; r++) {
      canvas.drawLine(Offset(0, r * cell), Offset(size.x, r * cell), grid);
    }
  }
}

typedef PieceEdges = ({int top, int right, int bottom, int left});

class JigsawPiece extends PositionComponent
    with DragCallbacks, TapCallbacks, HasGameReference<JigsawGame> {
  JigsawPiece({
    required this.row,
    required this.column,
    required this.cell,
    required this.tab,
    required this.edges,
    required this.image,
    required this.pixelRatio,
    required this.home,
    required super.position,
  }) : super(size: Vector2.all(cell + tab * 2), priority: 2) {
    _path = _buildPath();
  }

  final int row;
  final int column;
  final double cell;
  final double tab;
  final PieceEdges edges;
  final ui.Image image;
  final double pixelRatio;
  final Vector2 home;
  late final Path _path;
  bool placed = false;
  bool selected = false;
  bool _dragging = false;
  static int _topPriority = 10;

  Path _buildPath() {
    final path = Path()..moveTo(tab, tab);
    void edge(Offset a, Offset b, int dir) {
      if (dir == 0) {
        path.lineTo(b.dx, b.dy);
        return;
      }
      final d = b - a;
      final n = Offset(d.dy, -d.dx) / d.distance;
      final h = tab * dir;
      Offset u(double f) => a + d * f;
      path
        ..lineTo(u(0.36).dx, u(0.36).dy)
        ..cubicTo(
          (u(0.28) + n * h * 0.55).dx,
          (u(0.28) + n * h * 0.55).dy,
          (u(0.30) + n * h * 1.08).dx,
          (u(0.30) + n * h * 1.08).dy,
          (u(0.5) + n * h * 1.08).dx,
          (u(0.5) + n * h * 1.08).dy,
        )
        ..cubicTo(
          (u(0.70) + n * h * 1.08).dx,
          (u(0.70) + n * h * 1.08).dy,
          (u(0.72) + n * h * 0.55).dx,
          (u(0.72) + n * h * 0.55).dy,
          u(0.64).dx,
          u(0.64).dy,
        )
        ..lineTo(b.dx, b.dy);
    }

    final tl = Offset(tab, tab);
    final tr = Offset(tab + cell, tab);
    final br = Offset(tab + cell, tab + cell);
    final bl = Offset(tab, tab + cell);
    edge(tl, tr, edges.top);
    edge(tr, br, edges.right);
    edge(br, bl, edges.bottom);
    edge(bl, tl, edges.left);
    return path..close();
  }

  @override
  bool containsLocalPoint(Vector2 point) =>
      !placed && _path.contains(point.toOffset());

  @override
  void onTapUp(TapUpEvent event) {
    if (!placed) game.select(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (placed) return;
    _dragging = true;
    priority = ++_topPriority;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_dragging) return;
    position += event.localDelta;
    position.x = position.x.clamp(-tab, game.size.x - size.x + tab);
    position.y = position.y.clamp(-tab, game.size.y - size.y + tab);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_dragging) return;
    _dragging = false;
    game.dropped(this);
  }

  void shake() {
    add(
      SequenceEffect([
        MoveByEffect(Vector2(8, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(-16, 0), EffectController(duration: 0.1)),
        MoveByEffect(Vector2(8, 0), EffectController(duration: 0.05)),
      ]),
    );
  }

  @override
  void render(ui.Canvas canvas) {
    if (!placed) {
      canvas.drawShadow(
        _path,
        const Color(0x6625365B),
        _dragging ? 10 : 4,
        false,
      );
    }
    canvas.save();
    canvas.clipPath(_path);
    // Source square around this cell, in image pixels.
    final left = (column * cell - tab) * pixelRatio;
    final top = (row * cell - tab) * pixelRatio;
    final full = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final source = Rect.fromLTWH(
      left,
      top,
      size.x * pixelRatio,
      size.y * pixelRatio,
    ).intersect(full);
    final destination = Rect.fromLTWH(
      (source.left - left) / pixelRatio,
      (source.top - top) / pixelRatio,
      source.width / pixelRatio,
      source.height / pixelRatio,
    );
    canvas.drawImageRect(image, source, destination, Paint());
    canvas.restore();
    canvas.drawPath(
      _path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 4 : 1.6
        ..color = selected
            ? AppTheme.violet
            : Colors.white.withValues(alpha: placed ? 0.35 : 0.9),
    );
  }
}
