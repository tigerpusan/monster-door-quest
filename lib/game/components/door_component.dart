import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

/// V7.1.6
/// - Keeps the quick arched opening animation.
/// - Removes the mismatched fluorescent outline.
/// - Shows a clear O / X style success mark in the center of the door instead.
class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected})
      : super(anchor: Anchor.topLeft);

  final DoorSide side;
  final DoorSelected onSelected;

  final double openDuration = 0.18;
  final double visualDuration = 0.38;

  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  double _visualElapsed = 0;
  double _resultTimer = 0;
  double _pressFlash = 0;
  bool _firedThisTap = false;

  void pressDown() {
    isPressed = true;
    _pressFlash = 1;
  }

  void open({required bool correct}) {
    this.correct = correct;
    isOpening = true;
    _visualElapsed = 0;
    openProgress = 0;
    _resultTimer = .30;
    _pressFlash = 1;
  }

  void resetDoor() {
    isPressed = false;
    isOpening = false;
    correct = null;
    openProgress = 0;
    _visualElapsed = 0;
    _resultTimer = 0;
    _pressFlash = 0;
    _firedThisTap = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_firedThisTap) return;
    _firedThisTap = true;
    pressDown();
    onSelected(side);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    _firedThisTap = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    _firedThisTap = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isOpening) {
      _visualElapsed += dt;
      final t = (_visualElapsed / visualDuration).clamp(0.0, 1.0);
      if (t < .58) {
        openProgress = (t / .58).clamp(0.0, 1.0);
      } else if (t < .72) {
        openProgress = 1;
      } else {
        openProgress = (1 - ((t - .72) / .28)).clamp(0.0, 1.0);
      }
      if (t >= 1) {
        isOpening = false;
        openProgress = 0;
      }
    }
    if (_resultTimer > 0) {
      _resultTimer = (_resultTimer - dt).clamp(0, 1).toDouble();
      if (_resultTimer <= 0) correct = null;
    }
    if (_pressFlash > 0) {
      _pressFlash = (_pressFlash - dt * 5).clamp(0, 1).toDouble();
    }
  }

  double _easeOutCubic(double x) => 1 - math.pow(1 - x, 3).toDouble();

  Rect _leafBounds() {
    return Rect.fromLTWH(
      size.x * .105,
      size.y * .145,
      size.x * .79,
      size.y * .80,
    );
  }

  Path _archPath(Rect r) {
    final radius = r.width * .5;
    final springY = r.top + radius;
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, springY)
      ..arcTo(
        Rect.fromCircle(center: Offset(r.center.dx, springY), radius: radius),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(r.right, r.bottom)
      ..close();
  }

  void _drawCorrectMark(Canvas canvas, Rect leafBounds) {
    final center = Offset(leafBounds.center.dx, leafBounds.top + leafBounds.height * .54);
    final radius = leafBounds.width * .15;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = const Color(0xFF8DFF9E),
    );
  }

  void _drawWrongMark(Canvas canvas, Rect leafBounds) {
    final center = Offset(leafBounds.center.dx, leafBounds.top + leafBounds.height * .54);
    final half = leafBounds.width * .12;
    final paint = Paint()
      ..color = const Color(0xFFFF647E)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - half, center.dy - half),
      Offset(center.dx + half, center.dy + half),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + half, center.dy - half),
      Offset(center.dx - half, center.dy + half),
      paint,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final accent = side == DoorSide.left
        ? const Color(0xFF55CFFF)
        : const Color(0xFFFF72D7);
    final deep = side == DoorSide.left
        ? const Color(0xFF1439A5)
        : const Color(0xFF8B1E88);

    final leafBounds = _leafBounds();
    final arch = _archPath(leafBounds);

    if (isPressed || _pressFlash > 0) {
      canvas.drawPath(
        arch,
        Paint()..color = const Color(0x18FFFFFF),
      );
    }

    if (openProgress > 0) {
      final p = _easeOutCubic(openProgress);

      canvas.drawPath(
        arch,
        Paint()
          ..shader = Gradient.radial(
            leafBounds.center,
            leafBounds.width * .8,
            const [Color(0xFF4A2287), Color(0xFF12051F), Color(0xFF020106)],
            const [0.0, .55, 1.0],
          ),
      );
      canvas.drawPath(
        arch,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const Color(0xFFFFD975),
      );

      final scaleX = (1 - p * .90).clamp(.10, 1.0).toDouble();
      final hingeX = side == DoorSide.left ? leafBounds.left : leafBounds.right;
      canvas.save();
      canvas.translate(hingeX, 0);
      canvas.scale(scaleX, 1);
      canvas.translate(-hingeX, 0);

      canvas.drawPath(
        arch,
        Paint()
          ..shader = Gradient.linear(
            leafBounds.topLeft,
            leafBounds.bottomRight,
            [accent, deep],
          ),
      );
      canvas.drawPath(
        arch,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 / scaleX
          ..color = const Color(0xFFFFD66B),
      );
      canvas.restore();

      final edgeX = side == DoorSide.left
          ? leafBounds.left + leafBounds.width * scaleX
          : leafBounds.right - leafBounds.width * scaleX;
      canvas.drawLine(
        Offset(edgeX, leafBounds.top + leafBounds.height * .22),
        Offset(edgeX, leafBounds.bottom - 10),
        Paint()
          ..color = const Color(0xFFFFF1B5)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      for (var i = 0; i < 7; i++) {
        final a = (i + 1) / 8;
        final x = leafBounds.left + leafBounds.width * a;
        final y = leafBounds.top + leafBounds.height * (.28 + .08 * ((i * 3) % 7));
        canvas.drawCircle(
          Offset(x, y),
          1.8 + 3.0 * p,
          Paint()..color = const Color(0xFFFFE891).withValues(alpha: .18 + .58 * p),
        );
      }
    }

    if (correct != null) {
      if (correct!) {
        _drawCorrectMark(canvas, leafBounds);
      } else {
        _drawWrongMark(canvas, leafBounds);
      }
    }
  }
}
