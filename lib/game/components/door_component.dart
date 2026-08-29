import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

/// V7.1.1: the approved cute-art background already contains the door artwork.
/// This component is now a fast hit-area + opening/glow effect layer only.
class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected}) : super(anchor: Anchor.topLeft);

  final DoorSide side;
  final DoorSelected onSelected;
  final double openDuration = 0.14;

  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  bool _locked = false;
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
    _highlight = 1;
  }

  void resetDoor() {
    isPressed = false;
    isOpening = false;
    correct = null;
    openProgress = 0;
    _locked = false;
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
    if (_highlight > 0) {
      _highlight = (_highlight - dt * 4.2).clamp(0, 1).toDouble();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final accent = side == DoorSide.left ? const Color(0xFF6EC8FF) : const Color(0xFFFF82D9);
    final rect = RRect.fromRectAndRadius(size.toRect().deflate(3), Radius.circular(size.x * .14));

    if (isPressed || _highlight > 0) {
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 + 4 * _highlight
          ..color = accent.withValues(alpha: .45 + .35 * _highlight)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    if (openProgress > 0) {
      final inner = Rect.fromLTWH(size.x * .12, size.y * .12, size.x * .76, size.y * .80);
      final eased = 1 - math.pow(1 - openProgress, 3).toDouble();
      final portal = RRect.fromRectAndRadius(inner, Radius.circular(size.x * .10));
      canvas.drawRRect(portal, Paint()..color = const Color(0xDD100B2B));

      // Simulated fast door leaf sliding away from the center.
      final leafWidth = inner.width * (1 - eased);
      final leafRect = side == DoorSide.left
          ? Rect.fromLTWH(inner.left, inner.top, leafWidth, inner.height)
          : Rect.fromLTWH(inner.right - leafWidth, inner.top, leafWidth, inner.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(leafRect, Radius.circular(size.x * .08)),
        Paint()..color = accent.withValues(alpha: .60),
      );

      for (var i = 0; i < 6; i++) {
        final a = (i + 1) / 7;
        final x = inner.left + inner.width * a;
        final y = inner.top + inner.height * (.18 + .12 * ((i * 3) % 5));
        canvas.drawCircle(
          Offset(x, y),
          2 + 3 * eased,
          Paint()..color = const Color(0xFFFFE891).withValues(alpha: .2 + .7 * eased),
        );
      }
    }

    if (correct != null) {
      final c = correct! ? const Color(0xFF7CFF9A) : const Color(0xFFFF5576);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = c.withValues(alpha: .9),
      );
    }
  }
}
