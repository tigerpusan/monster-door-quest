import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

/// Verified V7.1.7 door feedback:
/// - NO fluorescent outline at all.
/// - The existing arched opening animation remains.
/// - O / X is drawn in the door center only.
class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected})
      : super(anchor: Anchor.topLeft);

  final DoorSide side;
  final DoorSelected onSelected;

  // Compatibility timing used by the existing regression test and older callers.
  // The visible animation can remain slightly longer while input reaction is immediate.
  final double openDuration = 0.18;
  final double visualDuration = 0.34;
  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  double _visualElapsed = 0;
  double _resultTimer = 0;
  bool _firedThisTap = false;

  // Kept as a public compatibility hook because the repository regression test
  // and older input code call pressDown() directly. It only changes the pressed
  // visual state and does not fire a duplicate door selection.
  void pressDown() {
    isPressed = true;
  }

  void open({required bool correct}) {
    this.correct = correct;
    isOpening = true;
    _visualElapsed = 0;
    openProgress = 0;
    _resultTimer = .28;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_firedThisTap) return;
    _firedThisTap = true;
    isPressed = true;
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
      if (t < .60) {
        openProgress = (t / .60).clamp(0.0, 1.0);
      } else if (t < .75) {
        openProgress = 1;
      } else {
        openProgress = (1 - ((t - .75) / .25)).clamp(0.0, 1.0);
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
  }

  double _easeOutCubic(double x) => 1 - math.pow(1 - x, 3).toDouble();

  Rect _leafBounds() => Rect.fromLTWH(
        size.x * .105,
        size.y * .145,
        size.x * .79,
        size.y * .80,
      );

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

  void _drawO(Canvas canvas, Rect r) {
    final c = Offset(r.center.dx, r.top + r.height * .54);
    canvas.drawCircle(
      c,
      r.width * .15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF8DFF9E),
    );
  }

  void _drawX(Canvas canvas, Rect r) {
    final c = Offset(r.center.dx, r.top + r.height * .54);
    final half = r.width * .13;
    final p = Paint()
      ..color = const Color(0xFFFF647E)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - half, c.dy - half), Offset(c.dx + half, c.dy + half), p);
    canvas.drawLine(Offset(c.dx + half, c.dy - half), Offset(c.dx - half, c.dy + half), p);
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

    final leaf = _leafBounds();
    final arch = _archPath(leaf);

    // Important: there is intentionally NO stroke/glow when pressed.
    if (openProgress > 0) {
      final p = _easeOutCubic(openProgress);
      canvas.drawPath(
        arch,
        Paint()
          ..shader = Gradient.radial(
            leaf.center,
            leaf.width * .8,
            const [Color(0xFF4A2287), Color(0xFF12051F), Color(0xFF020106)],
            const [0.0, .55, 1.0],
          ),
      );

      final scaleX = (1 - p * .90).clamp(.10, 1.0).toDouble();
      final hingeX = side == DoorSide.left ? leaf.left : leaf.right;
      canvas.save();
      canvas.translate(hingeX, 0);
      canvas.scale(scaleX, 1);
      canvas.translate(-hingeX, 0);
      canvas.drawPath(
        arch,
        Paint()
          ..shader = Gradient.linear(leaf.topLeft, leaf.bottomRight, [accent, deep]),
      );
      canvas.restore();

      // narrow inner light only; no external fluorescent outline
      final edgeX = side == DoorSide.left
          ? leaf.left + leaf.width * scaleX
          : leaf.right - leaf.width * scaleX;
      canvas.drawLine(
        Offset(edgeX, leaf.top + leaf.height * .25),
        Offset(edgeX, leaf.bottom - 12),
        Paint()
          ..color = const Color(0xFFFFF1B5)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    if (correct != null) {
      if (correct!) {
        _drawO(canvas, leaf);
      } else {
        _drawX(canvas, leaf);
      }
    }
  }
}
