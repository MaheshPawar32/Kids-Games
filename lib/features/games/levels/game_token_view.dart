import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import 'level_round.dart';

/// Renders one [GameToken] at [size] logical pixels.
class GameTokenView extends StatelessWidget {
  const GameTokenView(
    this.token, {
    this.size = 56,
    this.highlightGap = false,
    this.excludeSemantics = false,
    super.key,
  });

  final GameToken token;
  final double size;
  final bool highlightGap;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final child = switch (token.kind) {
      TokenKind.emoji => _emoji(),
      TokenKind.text => _text(context),
      TokenKind.colorSwatch => _swatch(),
      TokenKind.shape => SizedBox.square(
        dimension: size * token.scale,
        child: CustomPaint(
          painter: ShapeTokenPainter(
            token.shape!,
            Color(token.colorValue!),
            rotation: token.rotation,
          ),
        ),
      ),
      TokenKind.gap => _gap(),
    };
    if (excludeSemantics) return ExcludeSemantics(child: child);
    return Semantics(
      label: token.accessibleLabel,
      excludeSemantics: true,
      child: child,
    );
  }

  Widget _emoji() {
    final glyph = Text(
      token.value,
      textAlign: TextAlign.center,
      // Emoji keep their size when the system font is enlarged; the
      // surrounding layout already uses large touch targets.
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size * 0.72 * token.scale, height: 1.1),
    );
    if (!token.silhouette) return glyph;
    // A real silhouette: the emoji itself, filled solid.
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Color(0xFF2D3450), BlendMode.srcIn),
      child: glyph,
    );
  }

  Widget _text(BuildContext context) => Text(
    token.value,
    textAlign: TextAlign.center,
    maxLines: 1,
    softWrap: false,
    style: TextStyle(
      color: AppTheme.ink,
      fontSize: size * 0.48 * token.scale,
      fontWeight: FontWeight.w900,
      letterSpacing: token.value.length > 4 ? 1.5 : 0,
    ),
  );

  Widget _swatch() {
    final color = Color(token.colorValue!);
    final light = color.computeLuminance() > 0.55;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.4),
            border: Border.all(
              color: light ? const Color(0xFFCBD2E1) : Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Colour names are always shown so colour is never the only cue.
        Text(
          token.label,
          style: TextStyle(
            fontSize: math.max(12, size * 0.22),
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _gap() => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: highlightGap
          ? const Color(0xFFE2F6EA)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(size * 0.28),
      border: Border.all(
        color: highlightGap ? const Color(0xFF2E9E5B) : AppTheme.violet,
        width: 2.5,
      ),
    ),
    child: Text(
      '?',
      style: TextStyle(
        fontSize: size * 0.5,
        fontWeight: FontWeight.w900,
        color: AppTheme.violet,
      ),
    ),
  );
}

/// Paints a [ShapeKind] with a soft gradient, white rim and shadow.
class ShapeTokenPainter extends CustomPainter {
  const ShapeTokenPainter(this.shape, this.color, {this.rotation = 0});

  final ShapeKind shape;
  final Color color;

  /// Fraction of a full turn.
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.74,
      height: size.height * 0.74,
    );
    final path = shapePath(shape, rect);
    canvas.drawShadow(path, const Color(0x5525365B), size.width * 0.05, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.42)!,
            color,
            Color.lerp(color, Colors.black, 0.12)!,
          ],
          stops: const [0, 0.58, 1],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.025
        ..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.restore();
  }

  static Path shapePath(ShapeKind shape, Rect rect) {
    Path polygon(int sides, {double startAngle = -math.pi / 2}) {
      final path = Path();
      final radius = rect.shortestSide / 2;
      for (var i = 0; i < sides; i++) {
        final angle = startAngle + i * 2 * math.pi / sides;
        final point =
            rect.center +
            Offset(math.cos(angle) * radius, math.sin(angle) * radius);
        i == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      return path..close();
    }

    switch (shape) {
      case ShapeKind.circle:
        return Path()..addOval(rect);
      case ShapeKind.oval:
        return Path()..addOval(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width,
            height: rect.height * 0.62,
          ),
        );
      case ShapeKind.square:
        return Path()..addRRect(
          RRect.fromRectAndRadius(
            rect.deflate(rect.width * 0.06),
            Radius.circular(rect.width * 0.08),
          ),
        );
      case ShapeKind.rectangle:
        return Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: rect.center,
              width: rect.width,
              height: rect.height * 0.58,
            ),
            Radius.circular(rect.width * 0.07),
          ),
        );
      case ShapeKind.diamond:
        return Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right - rect.width * 0.18, rect.center.dy)
          ..lineTo(rect.center.dx, rect.bottom)
          ..lineTo(rect.left + rect.width * 0.18, rect.center.dy)
          ..close();
      case ShapeKind.triangle:
        return Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom - rect.height * 0.06)
          ..lineTo(rect.left, rect.bottom - rect.height * 0.06)
          ..close();
      case ShapeKind.pentagon:
        return polygon(5);
      case ShapeKind.hexagon:
        return polygon(6, startAngle: 0);
      case ShapeKind.star:
        final path = Path();
        final outer = rect.shortestSide / 2;
        for (var point = 0; point < 10; point++) {
          final radius = point.isEven ? outer : outer * 0.45;
          final angle = -math.pi / 2 + point * math.pi / 5;
          final position =
              rect.center + Offset(math.cos(angle), math.sin(angle)) * radius;
          point == 0
              ? path.moveTo(position.dx, position.dy)
              : path.lineTo(position.dx, position.dy);
        }
        return path..close();
      case ShapeKind.heart:
        final w = rect.width;
        final h = rect.height;
        final l = rect.left;
        final t = rect.top;
        return Path()
          ..moveTo(l + w / 2, t + h * 0.92)
          ..cubicTo(
            l - w * 0.05,
            t + h * 0.55,
            l + w * 0.02,
            t + h * 0.08,
            l + w * 0.27,
            t + h * 0.1,
          )
          ..cubicTo(
            l + w * 0.4,
            t + h * 0.1,
            l + w * 0.48,
            t + h * 0.2,
            l + w / 2,
            t + h * 0.28,
          )
          ..cubicTo(
            l + w * 0.52,
            t + h * 0.2,
            l + w * 0.6,
            t + h * 0.1,
            l + w * 0.73,
            t + h * 0.1,
          )
          ..cubicTo(
            l + w * 0.98,
            t + h * 0.08,
            l + w * 1.05,
            t + h * 0.55,
            l + w / 2,
            t + h * 0.92,
          )
          ..close();
    }
  }

  @override
  bool shouldRepaint(covariant ShapeTokenPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.rotation != rotation;
}
