import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

/// V7.1.2: the approved art stays visible while closed. Once tapped, this
/// component covers the baked-in door with a portal and draws a fast swinging
/// door leaf so the player can clearly feel the door opening.
class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected})
      : super(anchor: Anchor.topLeft);

  final DoorSide side;
  final DoorSelected onSelected;
  final double openDuration = 0.16;

  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  bool _locked = false;
  double _inputLockRemaining = 0;
  double _resultTimer = 0;
  double _highlight = 0;

  void pressDown() {
    isPressed = true;
    _highlight = 1;
  }

  void open({required bool correct}) {
    this.correct = correct;
    isOpening = true;
    openProgress = 0;
    _locked = true;
    _inputLockRemaining = .045;
    _resultTimer = .22;
    _highlight = 1;
  }

  void resetDoor() {
    isPressed = false;
    isOpening = false;
    correct = null;
    openProgress = 0;
    _locked = false;
    _inputLockRemaining = 0;
    _resultTimer = 0;
    _highlight = 0;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_locked) return;
    pressDown();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (!_locked) isPressed = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_locked) return;
    isPressed = false;
    onSelected(side);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isOpening) {
      openProgress += dt / openDuration;
      if (openProgress >= 1) {
        openProgress = 1;
        isOpening = false;
      }
    }
    if (_inputLockRemaining > 0) {
      _inputLockRemaining = (_inputLockRemaining - dt).clamp(0, 1).toDouble();
      if (_inputLockRemaining <= 0) _locked = false;
    }
    if (_resultTimer > 0) {
      _resultTimer = (_resultTimer - dt).clamp(0, 1).toDouble();
      if (_resultTimer <= 0) correct = null;
    }
    if (_highlight > 0) {
      _highlight = (_highlight - dt * 5).clamp(0, 1).toDouble();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final accent = side == DoorSide.left
        ? const Color(0xFF56C8FF)
        : const Color(0xFFFF72D4);
    final darkAccent = side == DoorSide.left
        ? const Color(0xFF1946B8)
        : const Color(0xFF9A268D);
    final frame = RRect.fromRectAndRadius(
      size.toRect().deflate(3),
      Radius.circular(size.x * .14),
    );

    if (isPressed || _highlight > 0) {
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 + 3 * _highlight
          ..color = accent.withValues(alpha: .30 + .30 * _highlight)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    if (openProgress > 0) {
      final inner = Rect.fromLTWH(
        size.x * .08,
        size.y * .055,
        size.x * .84,
        size.y * .90,
      );
      final eased = 1 - math.pow(1 - openProgress, 3).toDouble();

      // Hide the static baked-in door first, then reveal a deep portal.
      final portal = RRect.fromRectAndRadius(
        inner,
        Radius.circular(size.x * .10),
      );
      canvas.drawRRect(
        portal,
        Paint()
          ..shader = Gradient.linear(
            inner.topCenter,
            inner.bottomCenter,
            const [Color(0xFF060418), Color(0xFF20104A), Color(0xFF060418)],
          ),
      );
      canvas.drawRRect(
        portal,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = const Color(0xFFFFD66B).withValues(alpha: .75),
      );

      // Perspective-like swing: the door gets narrower around its outer hinge.
      final widthFactor = (1 - eased * .94).clamp(.06, 1.0).toDouble();
      final movingWidth = inner.width * widthFactor;
      final hingeX = side == DoorSide.left ? inner.left : inner.right;
      final leafRect = side == DoorSide.left
          ? Rect.fromLTWH(hingeX, inner.top, movingWidth, inner.height)
          : Rect.fromLTWH(hingeX - movingWidth, inner.top, movingWidth, inner.height);
      final leaf = RRect.fromRectAndRadius(
        leafRect,
        Radius.circular(size.x * .085 * widthFactor),
      );

      canvas.drawRRect(
        leaf,
        Paint()
          ..shader = Gradient.linear(
            leafRect.topLeft,
            leafRect.bottomRight,
            [accent, darkAccent],
          ),
      );
      canvas.drawRRect(
        leaf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = const Color(0xFFFFD66B),
      );

      if (movingWidth > inner.width * .24) {
        final gemCenter = Offset(
          leafRect.center.dx,
          leafRect.top + leafRect.height * .30,
        );
        final gemPath = Path()
          ..moveTo(gemCenter.dx, gemCenter.dy - 15)
          ..lineTo(gemCenter.dx + 11, gemCenter.dy)
          ..lineTo(gemCenter.dx, gemCenter.dy + 15)
          ..lineTo(gemCenter.dx - 11, gemCenter.dy)
          ..close();
        canvas.drawPath(gemPath, Paint()..color = const Color(0xFFE9F9FF));
        canvas.drawPath(
          gemPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFFFD66B),
        );
      }

      final edgeX = side == DoorSide.left ? leafRect.right : leafRect.left;
      canvas.drawRect(
        Rect.fromLTWH(edgeX - 4, inner.top + 6, 8, inner.height - 12),
        Paint()
          ..color = const Color(0xAA000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Portal spark particles reinforce the opening motion without heavy assets.
      for (var i = 0; i < 7; i++) {
        final a = (i + 1) / 8;
        final x = inner.left + inner.width * a;
        final y = inner.top + inner.height * (.15 + .11 * ((i * 3) % 6));
        canvas.drawCircle(
          Offset(x, y),
          2 + 3 * eased,
          Paint()
            ..color = const Color(0xFFFFE891).withValues(alpha: .18 + .70 * eased),
        );
      }
    }

    if (correct != null) {
      final c = correct! ? const Color(0xFF77FF9C) : const Color(0xFFFF5576);
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = c.withValues(alpha: .85),
      );
    }
  }
}
