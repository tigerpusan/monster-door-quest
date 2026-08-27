import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, LinearGradient, TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;
import '../components/action_button.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);

  final GameSessionState session;
  final double? memorySeconds;
  double elapsed = 0;
  late final ActionButton ready;
  bool _transitioned = false;

  @override
  Future<void> onLoad() async {
    ready = ActionButton(label: '기억 완료 · 도전!', onPressed: _goDoor);
    add(ready);
  }

  void _goDoor() {
    if (_transitioned) return;
    _transitioned = true;
    game.showDoorScene(session);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    ready.size = Vector2(size.x - 40, 62);
    ready.position = Vector2(20, size.y - 86);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (memorySeconds != null && !_transitioned) {
      elapsed += dt;
      if (elapsed >= memorySeconds! && isMounted) {
        _goDoor();
      }
    }
  }

  void _text(
    Canvas c,
    String text,
    double y,
    double fs, {
    Color color = const Color(0xFFFFFFFF),
    FontWeight fw = FontWeight.w700,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fs, fontWeight: fw)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x - 40);
    tp.paint(c, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF2D154C), Color(0xFF160A31), Color(0xFF08030F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(size.toRect()),
    );

    _text(canvas, '문 순서를 기억하세요', 36, 29, color: const Color(0xFFFFDF72), fw: FontWeight.w900);
    _text(canvas, 'STAGE ${session.stage} · ${session.route.length} DOORS', 76, 15, color: const Color(0xFFD9C9F5));

    final panel = RRect.fromRectAndRadius(Rect.fromLTWH(18, 112, size.x - 36, size.y - 218), const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0x66130B28));
    canvas.drawRRect(panel, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0x55C99DFF));

    final top = 146.0;
    final rowH = ((size.y - 320) / session.route.length).clamp(34.0, 56.0);
    for (var i = 0; i < session.route.length; i++) {
      final y = top + i * rowH;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(34, y, size.x - 68, rowH - 6), const Radius.circular(20));
      final isLeft = session.route[i].name == 'left';
      canvas.drawRRect(r, Paint()..color = const Color(0xFF30144A));
      canvas.drawRRect(r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = (isLeft ? const Color(0x664CC6FF) : const Color(0x66FF86E6)));
      _text(canvas, '${i + 1}   ${isLeft ? '← 왼쪽' : '오른쪽 →'}', y + 7, 17, color: isLeft ? const Color(0xFF8FE6FF) : const Color(0xFFFFC2F5));
    }

    if (memorySeconds != null) {
      final remain = (memorySeconds! - elapsed).clamp(0, memorySeconds!);
      final progress = remain / memorySeconds!;
      final barRect = Rect.fromLTWH(36, size.y - 140, size.x - 72, 14);
      canvas.drawRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(10)), Paint()..color = const Color(0x333F2A5E));
      final fill = Rect.fromLTWH(barRect.left, barRect.top, barRect.width * progress, barRect.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fill, const Radius.circular(10)),
        Paint()..shader = const LinearGradient(colors: [Color(0xFFFFD466), Color(0xFFFF7DD0)]).createShader(fill),
      );
      _text(canvas, '기억 시간 ${remain.toStringAsFixed(1)}초', size.y - 166, 16, color: const Color(0xFFFFE38A));
    } else {
      _text(canvas, '자동 진행 없음 · 준비되면 도전하세요', size.y - 148, 15, color: const Color(0xFFE8D8FF));
    }
  }
}
