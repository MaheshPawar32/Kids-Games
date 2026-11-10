import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/repositories/game_session_repository.dart';

enum _ShapeKind {
  circle,
  square,
  triangle,
  star,
  rectangle,
}

extension on _ShapeKind {
  String get label {
    switch (this) {
      case _ShapeKind.circle:
        return 'Circle';
      case _ShapeKind.square:
        return 'Square';
      case _ShapeKind.triangle:
        return 'Triangle';
      case _ShapeKind.star:
        return 'Star';
      case _ShapeKind.rectangle:
        return 'Rectangle';
    }
  }

  Color get color {
    switch (this) {
      case _ShapeKind.circle:
        return const Color(0xFF59B9EF);
      case _ShapeKind.square:
        return const Color(0xFF967CEB);
      case _ShapeKind.triangle:
        return const Color(0xFFFFA45F);
      case _ShapeKind.star:
        return const Color(0xFFFFC94F);
      case _ShapeKind.rectangle:
        return const Color(0xFF66C99B);
    }
  }
}

class _ShapeQuestion {
  const _ShapeQuestion({
    required this.target,
    required this.options,
  });

  final _ShapeKind target;
  final List<_ShapeKind> options;
}

class ShapeMatchingGameScreen extends StatefulWidget {
  const ShapeMatchingGameScreen({required this.sessionRepository, super.key});

  final GameSessionRepository sessionRepository;

  @override
  State<ShapeMatchingGameScreen> createState() =>
      _ShapeMatchingGameScreenState();
}

class _ShapeMatchingGameScreenState extends State<ShapeMatchingGameScreen> {
  static const _questions = [
    _ShapeQuestion(
      target: _ShapeKind.circle,
      options: [
        _ShapeKind.square,
        _ShapeKind.circle,
        _ShapeKind.triangle,
        _ShapeKind.star,
      ],
    ),
    _ShapeQuestion(
      target: _ShapeKind.triangle,
      options: [
        _ShapeKind.star,
        _ShapeKind.rectangle,
        _ShapeKind.triangle,
        _ShapeKind.circle,
      ],
    ),
    _ShapeQuestion(
      target: _ShapeKind.star,
      options: [
        _ShapeKind.circle,
        _ShapeKind.square,
        _ShapeKind.star,
        _ShapeKind.triangle,
      ],
    ),
    _ShapeQuestion(
      target: _ShapeKind.rectangle,
      options: [
        _ShapeKind.triangle,
        _ShapeKind.rectangle,
        _ShapeKind.circle,
        _ShapeKind.square,
      ],
    ),
    _ShapeQuestion(
      target: _ShapeKind.square,
      options: [
        _ShapeKind.square,
        _ShapeKind.star,
        _ShapeKind.circle,
        _ShapeKind.triangle,
      ],
    ),
  ];

  int _questionIndex = 0;
  int _score = 0;
  _ShapeKind? _selectedAnswer;
  bool _finished = false;
  bool _saving = false;
  bool _saveError = false;

  _ShapeQuestion get _question => _questions[_questionIndex];

  bool get _isAnswerCorrect => _selectedAnswer == _question.target;

  void _selectAnswer(_ShapeKind shape) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = shape;
      if (shape == _question.target) {
        _score++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_questionIndex == _questions.length - 1) {
      setState(() {
        _finished = true;
        _saving = true;
        _saveError = false;
      });
      final completedAt = DateTime.now();
      try {
        await widget.sessionRepository.recordSession(
          GameSession(
            id: 'shape_matching_${completedAt.microsecondsSinceEpoch}',
            activityId: 'shape_matching',
            score: _score,
            totalRounds: _questions.length,
            completedAt: completedAt,
          ),
        );
      } on Object {
        if (mounted) setState(() => _saveError = true);
      } finally {
        if (mounted) setState(() => _saving = false);
      }
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
    });
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _finished = false;
      _saving = false;
      _saveError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Shape Matching'),
        leading: IconButton(
          tooltip: 'Back to games',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: _finished ? _buildFinishedScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    final progress = (_questionIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'ROUND ${_questionIndex + 1} OF ${_questions.length}',
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, color: Color(0xFFFFBD45)),
              const SizedBox(width: 4),
              Text(
                _score.toString(),
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFE2E7F1),
              color: AppTheme.violet,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Find the same shape',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Look at the shape, then tap its matching friend.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF71809B)),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1025365B),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'MATCH THIS SHAPE',
                  style: TextStyle(
                    color: Color(0xFF8B95A9),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: _question.target.label,
                  child: CustomPaint(
                    size: const Size(150, 150),
                    painter: _ShapePainter(_question.target),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _question.target.label,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'TAP YOUR ANSWER',
            style: TextStyle(
              color: Color(0xFF8B95A9),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _question.options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.28,
            ),
            itemBuilder: (context, index) {
              final shape = _question.options[index];
              final selected = _selectedAnswer == shape;
              final isCorrect = shape == _question.target;
              final answered = _selectedAnswer != null;
              Color borderColor = Colors.transparent;
              if (answered && selected) {
                borderColor = isCorrect
                    ? const Color(0xFF52B98A)
                    : const Color(0xFFE98686);
              } else if (answered && isCorrect) {
                borderColor = const Color(0xFF52B98A);
              }

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  key: Key('shape_option_${shape.name}'),
                  borderRadius: BorderRadius.circular(22),
                  onTap: answered ? null : () => _selectAnswer(shape),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: borderColor,
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D25365B),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(72, 72),
                          painter: _ShapePainter(shape),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shape.label,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedAnswer != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _isAnswerCorrect
                    ? const Color(0xFFE5F7EE)
                    : const Color(0xFFFFECE7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAnswerCorrect
                        ? Icons.check_circle_rounded
                        : Icons.favorite_rounded,
                    color: _isAnswerCorrect
                        ? const Color(0xFF329A6B)
                        : const Color(0xFFE18470),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isAnswerCorrect
                          ? 'Great matching! You found the ${_question.target.label.toLowerCase()}.'
                          : 'Good try! The matching shape is ${_question.target.label.toLowerCase()}.',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                key: const Key('next_shape_button'),
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.violet,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _questionIndex == _questions.length - 1
                      ? 'See my score'
                      : 'Next shape',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinishedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1D4),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🏆', style: TextStyle(fontSize: 68)),
            ),
            const SizedBox(height: 24),
            Text(
              'Shape explorer!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$_score out of ${_questions.length} correct',
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Every try helps your brain grow.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF71809B)),
            ),
            const SizedBox(height: 8),
            Text(
              _saving
                  ? 'Saving your progress…'
                  : _saveError
                      ? 'Progress could not be saved. Please try again.'
                      : 'Progress saved on this device.',
              key: const Key('session_save_status'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _restart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.violet,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Play again',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 8),
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

class _ShapePainter extends CustomPainter {
  const _ShapePainter(this.shape);

  final _ShapeKind shape;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.72;
    final height = size.height * 0.72;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: width,
      height: height,
    );
    final path = _buildPath(rect);

    canvas.drawShadow(
      path,
      const Color(0x5525365B),
      size.width * 0.055,
      true,
    );

    final base = shape.color;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(base, Colors.white, 0.42)!,
          base,
          Color.lerp(base, Colors.black, 0.12)!,
        ],
        stops: const [0, 0.58, 1],
      ).createShader(rect);

    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.025
        ..color = Colors.white.withValues(alpha: 0.72),
    );
  }

  Path _buildPath(Rect rect) {
    switch (shape) {
      case _ShapeKind.circle:
        return Path()..addOval(rect);
      case _ShapeKind.square:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(9)),
          );
      case _ShapeKind.rectangle:
        final inner = Rect.fromCenter(
          center: rect.center,
          width: rect.width,
          height: rect.height * 0.68,
        );
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(inner, const Radius.circular(8)),
          );
      case _ShapeKind.triangle:
        return Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
      case _ShapeKind.star:
        final path = Path();
        final center = rect.center;
        final outerRadius = rect.shortestSide / 2;
        final innerRadius = outerRadius * 0.43;
        for (var point = 0; point < 10; point++) {
          final radius = point.isEven ? outerRadius : innerRadius;
          final angle = -math.pi / 2 + point * math.pi / 5;
          final position = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle),
          );
          if (point == 0) {
            path.moveTo(position.dx, position.dy);
          } else {
            path.lineTo(position.dx, position.dy);
          }
        }
        return path..close();
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.shape != shape;
  }
}
