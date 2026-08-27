import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show Alignment, LinearGradient, RadialGradient;
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected}) : super(anchor: Anchor.topLeft);

  final DoorSide side;
  final DoorSelected onSelected;
  final double openDuration = 0.16;

  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  bool _locked = false;
  double _highlight = 0;

  void pressDown() {
    isPressed = true;
    scale = Vector2.all(.982);
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
    scale = Vector2.all(1);
    _highlight = 0;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_locked) return;
    pressDown();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (!_locked) {
      isPressed = false;
      scale = Vector2.all(1);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_locked) return;
    isPressed = false;
    scale = Vector2.all(1);
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
      _highlight = (_highlight - dt * 2.8).clamp(0, 1).toDouble();
    }
  }

  Path _archPath(Rect rect) {
    final radius = rect.width * .30;
    final path = Path();
    path.moveTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.top + radius);
    path.quadraticBezierTo(rect.left, rect.top, rect.left + radius, rect.top);
    path.lineTo(rect.right - radius, rect.top);
    path.quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + radius);
    path.lineTo(rect.right, rect.bottom);
    path.close();
    return path;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final outerRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final innerRect = Rect.fromLTWH(12, 14, size.x - 24, size.y - 26);
    final auraColor = side == DoorSide.left ? const Color(0xFF4CC6FF) : const Color(0xFFF07CFF);
    final borderGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = auraColor.withOpacity(0.22 + (_highlight * 0.22));
    canvas.drawPath(_archPath(outerRect.inflate(2)), borderGlow);

    final framePath = _archPath(outerRect);
    final framePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE7A3), Color(0xFFC69232), Color(0xFF7D4E17), Color(0xFFF6DE94)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(outerRect);
    canvas.drawPath(framePath, framePaint);

    final shadow = Paint()
      ..color = const Color(0x77000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(_archPath(innerRect.shift(const Offset(0, 8))), shadow);

    canvas.save();
    if (openProgress > 0) {
      final pivotX = side == DoorSide.left ? innerRect.left + 8 : innerRect.right - 8;
      final sx = 1 - openProgress * .84;
      canvas.translate(pivotX, 0);
      canvas.scale(sx, 1);
      canvas.translate(-pivotX, 0);
    }

    final leafPath = _archPath(innerRect);
    final leafPaint = Paint()
      ..shader = (side == DoorSide.left
              ? const LinearGradient(
                  colors: [Color(0xFF5D83FF), Color(0xFF304EC2), Color(0xFF1A2B76)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFD774FF), Color(0xFF9D41D0), Color(0xFF5E1C89)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ))
          .createShader(innerRect);
    canvas.drawPath(leafPath, leafPaint);

    final innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..shader = RadialGradient(
        colors: [auraColor.withOpacity(.6), const Color(0x00FFFFFF)],
      ).createShader(innerRect);
    canvas.drawPath(leafPath, innerGlow);

    final panelPaint = Paint()..color = const Color(0x20FFFFFF);
    for (var i = 0; i < 4; i++) {
      final top = innerRect.top + 36 + (i * innerRect.height * .16);
      final panel = RRect.fromRectAndRadius(
        Rect.fromLTWH(innerRect.left + 16, top, innerRect.width - 32, 22),
        const Radius.circular(12),
      );
      canvas.drawRRect(panel, panelPaint);
    }

    final gemCenter = Offset(size.x * .5, size.y * .20);
    final gem = Path()
      ..moveTo(gemCenter.dx, gemCenter.dy - 18)
      ..lineTo(gemCenter.dx + 15, gemCenter.dy)
      ..lineTo(gemCenter.dx, gemCenter.dy + 22)
      ..lineTo(gemCenter.dx - 15, gemCenter.dy)
      ..close();
    canvas.drawPath(gem, Paint()..color = side == DoorSide.left ? const Color(0xFF71E8FF) : const Color(0xFFF7A4FF));
    canvas.drawPath(gem, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFFFE396));

    final knobX = side == DoorSide.left ? size.x * .80 : size.x * .20;
    canvas.drawCircle(Offset(knobX, size.y * .58), 9, Paint()..color = const Color(0xFFFFD56E));
    canvas.drawCircle(Offset(knobX - 2, size.y * .56), 3, Paint()..color = const Color(0x66FFFFFF));
    canvas.restore();

    if (correct != null) {
      final pulse = 2 + math.sin(openProgress * math.pi) * 3;
      canvas.drawPath(
        framePath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = pulse
          ..color = correct! ? const Color(0xFF62FFB0) : const Color(0xFFFF5B78),
      );
    }
  }
}
