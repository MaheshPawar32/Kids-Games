import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class _PuzzlePiece {
  const _PuzzlePiece(this.id, this.emoji, this.label, this.color);

  final String id;
  final String emoji;
  final String label;
  final Color color;
}

const _pieces = <_PuzzlePiece>[
  _PuzzlePiece('sun', '☀️', 'Sun', Color(0xFFFFD36E)),
  _PuzzlePiece('cloud', '☁️', 'Cloud', Color(0xFFB7DDF7)),
  _PuzzlePiece('tree', '🌳', 'Tree', Color(0xFF9DE2C2)),
  _PuzzlePiece('flower', '🌼', 'Flower', Color(0xFFFFB6C8)),
];

class JigsawPuzzlesGameScreen extends StatefulWidget {
  const JigsawPuzzlesGameScreen({super.key});

  @override
  State<JigsawPuzzlesGameScreen> createState() =>
      _JigsawPuzzlesGameScreenState();
}

class _JigsawPuzzlesGameScreenState extends State<JigsawPuzzlesGameScreen> {
  final Set<String> _placed = <String>{};
  int _moves = 0;

  bool get _completed => _placed.length == _pieces.length;

  void _place(String id, String targetId) {
    if (id != targetId || _placed.contains(id)) return;
    setState(() {
      _placed.add(id);
      _moves++;
    });
  }

  void _restart() {
    setState(() {
      _placed.clear();
      _moves = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Jigsaw Puzzles'),
        leading: IconButton(
          tooltip: 'Back to games',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: _completed ? _result() : _game(),
      ),
    );
  }

  Widget _game() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _placed.length / _pieces.length,
                    minHeight: 10,
                    backgroundColor: Colors.white,
                    color: AppTheme.violet,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_placed.length}/${_pieces.length}',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 22),
          Text('Build the sunny garden!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Drag each picture piece into its matching space.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF71809B))),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(color: Color(0x1025365B), blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            child: GridView.builder(
              key: const Key('jigsaw_board'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pieces.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final piece = _pieces[index];
                final filled = _placed.contains(piece.id);
                return DragTarget<String>(
                  key: Key('jigsaw_slot_${piece.id}'),
                  onWillAcceptWithDetails: (details) =>
                      details.data == piece.id && !filled,
                  onAcceptWithDetails: (details) => _place(details.data, piece.id),
                  builder: (context, candidates, rejected) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: filled ? piece.color.withValues(alpha: 0.32) : const Color(0xFFF3F5FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: candidates.isNotEmpty ? AppTheme.violet : const Color(0xFFDCE2ED),
                        width: candidates.isNotEmpty ? 3 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: filled
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(piece.emoji, style: const TextStyle(fontSize: 48)),
                                Text(piece.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            )
                          : const Icon(Icons.extension_rounded, size: 42, color: Color(0xFFB5BDCC)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          const Text('PUZZLE PIECES',
              style: TextStyle(fontSize: 11, letterSpacing: 1.2,
                  fontWeight: FontWeight.w900, color: Color(0xFF8B95A9))),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: _pieces.map((piece) {
            final placed = _placed.contains(piece.id);
            final card = _pieceCard(piece, placed: placed);
            return Draggable<String>(
              key: Key('jigsaw_piece_${piece.id}'),
              data: piece.id,
              maxSimultaneousDrags: placed ? 0 : 1,
              feedback: Material(
                color: Colors.transparent,
                child: _pieceCard(piece, dragging: true),
              ),
              childWhenDragging: Opacity(opacity: 0.25, child: card),
              child: card,
            );
          }).toList(),
          ),
          const SizedBox(height: 14),
          Text('Moves: $_moves', textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF71809B), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _pieceCard(_PuzzlePiece piece, {bool dragging = false, bool placed = false}) {
    return Container(
      width: 112,
      height: 100,
      decoration: BoxDecoration(
        color: piece.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: dragging
            ? const [BoxShadow(color: Color(0x3325365B), blurRadius: 12)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(piece.emoji, style: const TextStyle(fontSize: 38)),
          Text(placed ? '${piece.label} ✓' : piece.label,
              style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _result() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌈', style: TextStyle(fontSize: 76)),
            const SizedBox(height: 14),
            Text('Beautifully completed!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('You built the whole sunny garden!',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Completed in $_moves moves',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('replay_jigsaw_button'),
                onPressed: _restart,
                child: const Text('Play again'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to games'),
            ),
          ],
        ),
      ),
    );
  }
}
