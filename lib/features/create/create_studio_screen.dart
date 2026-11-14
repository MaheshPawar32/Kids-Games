import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateStudioScreen extends StatefulWidget {
  const CreateStudioScreen({super.key});

  @override
  State<CreateStudioScreen> createState() => _CreateStudioScreenState();
}

class _CreateStudioScreenState extends State<CreateStudioScreen> {
  static const _storageKey = 'kids_games_saved_artwork_v1';
  static const _palette = <Color>[
    Color(0xFF172B4D),
    Color(0xFFEF476F),
    Color(0xFFFF9F1C),
    Color(0xFF06A77D),
    Color(0xFF2D7DD2),
    Color(0xFF8E5CE6),
    Color(0xFF111111),
  ];

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  final List<_DrawingStroke> _strokes = [];
  final List<_DrawingStroke> _redo = [];
  List<_SavedArtwork> _gallery = [];
  List<Offset>? _activePoints;
  Color _selectedColor = const Color(0xFF172B4D);
  double _brushSize = 5;
  bool _eraser = false;
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    try {
      final raw = await _preferences.getString(_storageKey);
      final decoded = raw == null
          ? <dynamic>[]
          : jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(_SavedArtwork.fromMap)
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _gallery = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _gallery = [];
        _loading = false;
        _message = 'Saved artwork could not be loaded. You can still draw.';
      });
    }
  }

  Offset _normalise(Offset point, Size size) {
    if (size.width <= 0 || size.height <= 0) return Offset.zero;
    return Offset(
      (point.dx / size.width).clamp(0.0, 1.0),
      (point.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _startStroke(DragStartDetails details, Size size) {
    setState(() {
      _redo.clear();
      _activePoints = [_normalise(details.localPosition, size)];
    });
  }

  void _extendStroke(DragUpdateDetails details, Size size) {
    final points = _activePoints;
    if (points == null) return;
    setState(() {
      points.add(_normalise(details.localPosition, size));
    });
  }

  void _finishStroke() {
    final points = _activePoints;
    if (points == null || points.isEmpty) return;
    setState(() {
      _strokes.add(
        _DrawingStroke(
          points: List<Offset>.unmodifiable(points),
          colorValue: _eraser
              ? Colors.white.toARGB32()
              : _selectedColor.toARGB32(),
          width: _brushSize,
        ),
      );
      _activePoints = null;
      _message = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redo.add(_strokes.removeLast());
    });
  }

  void _redoLast() {
    if (_redo.isEmpty) return;
    setState(() {
      _strokes.add(_redo.removeLast());
    });
  }

  Future<void> _clearCanvas() async {
    if (_strokes.isEmpty && _activePoints == null) return;
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start a fresh page?'),
        content: const Text(
          'This clears the current drawing. Saved pictures stay in your gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep drawing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear page'),
          ),
        ],
      ),
    );
    if (clear == true && mounted) {
      setState(() {
        _strokes.clear();
        _redo.clear();
        _activePoints = null;
        _message = null;
      });
    }
  }

  Future<void> _saveArtwork() async {
    if (_strokes.isEmpty) {
      setState(
        () => _message = 'Draw something first, then save your picture.',
      );
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController(text: 'My picture');
        return AlertDialog(
          title: const Text('Save your picture'),
          content: TextField(
            controller: controller,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Picture name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.pop(
                  dialogContext,
                  value.isEmpty ? 'My picture' : value,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (name == null || !mounted) return;

    final artwork = _SavedArtwork(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: name,
      savedAt: DateTime.now(),
      strokes: List<_DrawingStroke>.unmodifiable(_strokes),
    );
    final next = [artwork, ..._gallery].take(30).toList(growable: false);
    try {
      await _preferences.setString(
        _storageKey,
        jsonEncode(next.map((item) => item.toMap()).toList()),
      );
      if (!mounted) return;
      setState(() {
        _gallery = next;
        _strokes.clear();
        _redo.clear();
        _activePoints = null;
        _message = 'Picture saved in your gallery.';
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'We could not save this picture. Please try again.',
        );
      }
    }
  }

  Future<void> _openGallery() async {
    await _loadGallery();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF4F6FC),
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'My gallery',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text('${_gallery.length} saved pictures on this device'),
                const SizedBox(height: 12),
                Expanded(
                  child: _gallery.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🖼️', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 8),
                              Text('Your saved pictures will appear here.'),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _gallery.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _gallery[index];
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFFFE8AF),
                                  child: Icon(Icons.brush_rounded),
                                ),
                                title: Text(item.title),
                                subtitle: Text(_dateLabel(item.savedAt)),
                                trailing: const Icon(Icons.visibility_outlined),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  _previewArtwork(item);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  void _previewArtwork(_SavedArtwork artwork) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(artwork.title),
        content: SizedBox(
          width: 320,
          height: 300,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE4E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _DrawingPainter(strokes: artwork.strokes),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteArtwork(artwork.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArtwork(String id) async {
    final next = _gallery.where((item) => item.id != id).toList();
    try {
      await _preferences.setString(
        _storageKey,
        jsonEncode(next.map((item) => item.toMap()).toList()),
      );
      if (mounted) setState(() => _gallery = next);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'We could not delete that picture.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Creative studio',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Draw, choose colors and save your own pictures.',
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        key: const Key('create_gallery_button'),
                        tooltip: 'My gallery',
                        onPressed: _openGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildToolbar(),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 0.88,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        return Semantics(
                          label: 'Drawing canvas. Use a finger to draw.',
                          child: GestureDetector(
                            key: const Key('create_drawing_canvas'),
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) =>
                                _startStroke(details, size),
                            onPanUpdate: (details) =>
                                _extendStroke(details, size),
                            onPanEnd: (_) => _finishStroke(),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFDCE2EE),
                                ),
                              ),
                              child: CustomPaint(
                                painter: _DrawingPainter(
                                  strokes: _strokes,
                                  activePoints: _activePoints,
                                  activeColor: _eraser
                                      ? Colors.white
                                      : _selectedColor,
                                  activeWidth: _brushSize,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('create_undo_button'),
                          onPressed: _strokes.isEmpty ? null : _undo,
                          icon: const Icon(Icons.undo_rounded),
                          label: const Text('Undo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('create_redo_button'),
                          onPressed: _redo.isEmpty ? null : _redoLast,
                          icon: const Icon(Icons.redo_rounded),
                          label: const Text('Redo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('create_clear_button'),
                          onPressed: _strokes.isEmpty ? null : _clearCanvas,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Clear'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    key: const Key('create_save_button'),
                    onPressed: _saveArtwork,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: const Text('Save my picture'),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _message!,
                      key: const Key('create_status_message'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF49627C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Text(
                    'Your pictures stay on this device. You can open the gallery to view or delete them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Choose a color',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilterChip(
                  label: const Text('Eraser'),
                  selected: _eraser,
                  onSelected: (selected) {
                    setState(() => _eraser = selected);
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in _palette)
                  InkWell(
                    key: Key(
                      'create_color_${color.toARGB32().toRadixString(16)}',
                    ),
                    customBorder: const CircleBorder(),
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _eraser = false;
                      });
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color && !_eraser
                              ? const Color(0xFF172B4D)
                              : const Color(0xFFDCE2EE),
                          width: _selectedColor == color && !_eraser ? 3 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Brush size',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(_brushSize.round().toString()),
              ],
            ),
            Slider(
              key: const Key('create_brush_size'),
              value: _brushSize,
              min: 2,
              max: 18,
              divisions: 8,
              onChanged: (value) => setState(() => _brushSize = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingStroke {
  const _DrawingStroke({
    required this.points,
    required this.colorValue,
    required this.width,
  });

  final List<Offset> points;
  final int colorValue;
  final double width;

  Map<String, Object> toMap() => {
    'color': colorValue,
    'width': width,
    'points': points.map((point) => [point.dx, point.dy]).toList(),
  };

  factory _DrawingStroke.fromMap(Map<dynamic, dynamic> map) {
    final rawPoints = map['points'] as List<dynamic>? ?? [];
    return _DrawingStroke(
      colorValue: (map['color'] as num).toInt(),
      width: (map['width'] as num).toDouble(),
      points: rawPoints
          .whereType<List<dynamic>>()
          .where((point) => point.length == 2)
          .map(
            (point) => Offset(
              (point[0] as num).toDouble(),
              (point[1] as num).toDouble(),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SavedArtwork {
  const _SavedArtwork({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.strokes,
  });

  final String id;
  final String title;
  final DateTime savedAt;
  final List<_DrawingStroke> strokes;

  Map<String, Object> toMap() => {
    'id': id,
    'title': title,
    'saved_at': savedAt.toIso8601String(),
    'strokes': strokes.map((stroke) => stroke.toMap()).toList(),
  };

  factory _SavedArtwork.fromMap(Map<dynamic, dynamic> map) {
    final rawStrokes = map['strokes'] as List<dynamic>? ?? [];
    return _SavedArtwork(
      id: map['id'] as String,
      title: map['title'] as String,
      savedAt:
          DateTime.tryParse(map['saved_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      strokes: rawStrokes
          .whereType<Map<dynamic, dynamic>>()
          .map(_DrawingStroke.fromMap)
          .toList(growable: false),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter({
    required this.strokes,
    this.activePoints,
    this.activeColor = Colors.black,
    this.activeWidth = 5,
  });

  final List<_DrawingStroke> strokes;
  final List<Offset>? activePoints;
  final Color activeColor;
  final double activeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(
        canvas,
        size,
        stroke.points,
        Color(stroke.colorValue),
        stroke.width,
      );
    }
    if (activePoints != null) {
      _paintStroke(canvas, size, activePoints!, activeColor, activeWidth);
    }
  }

  void _paintStroke(
    Canvas canvas,
    Size size,
    List<Offset> points,
    Color color,
    double width,
  ) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (points.length == 1) {
      canvas.drawCircle(
        Offset(points.first.dx * size.width, points.first.dy * size.height),
        width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
