import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

/// V7.1.3: immediate input + a clearly visible open/hold/close visual cycle.
/// The visual animation never blocks the next answer.
class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected})
      : super(anchor: Anchor.topLeft);

  final DoorSide side;
  final DoorSelected onSelected;

  /// Kept short for tests/feel. Total visual cycle includes hold + close.
  final double openDuration = 0.18;
  final double visualDuration = 0.38;

  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  double _visualElapsed = 0;
  double _resultTimer = 0;
  double _highlight = 0;
  bool _firedThisTap = false;

  void pressDown() {
    isPressed = true;
    _highlight = 1;
  }

  void open({required bool correct}) {
    this.correct = correct;
    isOpening = true;
    _visualElapsed = 0;
    openProgress = 0;
    _resultTimer = .30;
    _highlight = 1;
  }

  void resetDoor() {
    isPressed = false;
    isOpening = false;
    correct = null;
    openProgress = 0;
    _visualElapsed = 0;
    _resultTimer = 0;
    _highlight = 0;
    _firedThisTap = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_firedThisTap) return;
    _firedThisTap = true;
    pressDown();
    // Fire on DOWN, not UP. This removes the perceived delay on rapid play.
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

      // 0-58% open, 58-72% hold, 72-100% close.
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
    if (_highlight > 0) {
      _highlight = (_highlight - dt * 5).clamp(0, 1).toDouble();
    }
  }

  double _easeOutCubic(double x) => 1 - math.pow(1 - x, 3).toDouble();

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final accent = side == DoorSide.left
        ? const Color(0xFF53C9FF)
        : const Color(0xFFFF72D4);
    final deep = side == DoorSide.left
        ? const Color(0xFF1439A5)
        : const Color(0xFF8B1E88);
    final frame = RRect.fromRectAndRadius(
      size.toRect().deflate(2),
      Radius.circular(size.x * .14),
    );

    // Tap response: quick glow + inward press.
    if (isPressed || _highlight > 0) {
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 + 4 * _highlight
          ..color = accent.withValues(alpha: .45 + .35 * _highlight)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }

    if (openProgress > 0) {
      final p = _easeOutCubic(openProgress);
      final inner = Rect.fromLTWH(
        size.x * .055,
        size.y * .035,
        size.x * .89,
        size.y * .93,
      );

      // Strong black/purple portal fully hides the static painted door beneath.
      final portal = RRect.fromRectAndRadius(inner, Radius.circular(size.x * .095));
      canvas.drawRRect(
        portal,
        Paint()
          ..shader = Gradient.radial(
            inner.center,
            inner.width * .75,
            const [Color(0xFF3D1A75), Color(0xFF12051F), Color(0xFF020106)],
            const [0.0, .52, 1.0],
          ),
      );
      canvas.drawRRect(
        portal,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..color = const Color(0xFFFFDB74),
      );

      // Door leaf collapses toward its OUTER hinge. This is deliberately high
      // contrast so the player can see the door swing even during fast taps.
      final widthFactor = (1 - p * .91).clamp(.09, 1.0).toDouble();
      final movingWidth = inner.width * widthFactor;
      final hingeX = side == DoorSide.left ? inner.left : inner.right;
      final leafRect = side == DoorSide.left
          ? Rect.fromLTWH(hingeX, inner.top, movingWidth, inner.height)
          : Rect.fromLTWH(hingeX - movingWidth, inner.top, movingWidth, inner.height);

      // Cast shadow behind the moving leaf.
      final shadowX = side == DoorSide.left ? leafRect.right : leafRect.left;
      canvas.drawRect(
        Rect.fromLTWH(shadowX - 13, inner.top + 8, 26, inner.height - 16),
        Paint()
          ..color = const Color(0xCC000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
      );

      final leaf = RRect.fromRectAndRadius(
        leafRect,
        Radius.circular(math.max(4, size.x * .085 * widthFactor)),
      );
      canvas.drawRRect(
        leaf,
        Paint()
          ..shader = Gradient.linear(
            leafRect.topLeft,
            leafRect.bottomRight,
            [accent, deep],
          ),
      );
      canvas.drawRRect(
        leaf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = const Color(0xFFFFD66B),
      );

      // Bright inner edge behaves like a 3D door thickness.
      final innerEdgeX = side == DoorSide.left ? leafRect.right : leafRect.left;
      canvas.drawRect(
        Rect.fromLTWH(innerEdgeX - 5, inner.top + 8, 10, inner.height - 16),
        Paint()..color = const Color(0xFFFFF1B5),
      );

      // Flash from the doorway makes the action unmistakable.
      final flashAlpha = (1 - (p - .72).abs() / .72).clamp(0.0, 1.0);
      canvas.drawRRect(
        portal,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..color = accent.withValues(alpha: .18 + .42 * flashAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      for (var i = 0; i < 9; i++) {
        final a = (i + 1) / 10;
        final x = inner.left + inner.width * a;
        final y = inner.top + inner.height * (.12 + .095 * ((i * 5) % 8));
        canvas.drawCircle(
          Offset(x, y),
          2.0 + 4.0 * p,
          Paint()..color = const Color(0xFFFFE891).withValues(alpha: .22 + .65 * p),
        );
      }

      // A speed slash in the opening direction adds a tactile hit feeling.
      final slashY = inner.center.dy;
      final slashStart = side == DoorSide.left
          ? Offset(inner.right - 8, slashY)
          : Offset(inner.left + 8, slashY);
      final slashEnd = side == DoorSide.left
          ? Offset(inner.left + 20, slashY - 18)
          : Offset(inner.right - 20, slashY - 18);
      canvas.drawLine(
        slashStart,
        slashEnd,
        Paint()
          ..color = const Color(0xAAFFFFFF)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    if (correct != null) {
      final c = correct! ? const Color(0xFF77FF9C) : const Color(0xFFFF5576);
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = c.withValues(alpha: .95),
      );
    }
  }
}
