import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);

  final GameSessionState session;
  final double? memorySeconds;
  late Sprite _bg;
  late TapZone _ready;
  double elapsed = 0;
  bool _transitioned = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/memory.webp');
    _ready = TapZone(onTap: _goDoor);
    add(_ready);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _ready
      ..size = Vector2(size.x * .76, size.y * .075)
      ..position = Vector2(size.x * .12, size.y * .84);
  }

  void _goDoor() {
    if (_transitioned) return;
    _transitioned = true;
    game.showDoorScene(session);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (memorySeconds != null && !_transitioned) {
      elapsed += dt;
      if (elapsed >= memorySeconds! && isMounted) _goDoor();
    }
  }

  void _text(Canvas canvas, String text, double x, double y, double fs, Color color, FontWeight weight, {double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: weight, color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? size.x);
    tp.paint(canvas, Offset(x, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    // Hide the fixed mockup route/stage and redraw live data in the same cute style.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .14, size.y * .205, size.x * .72, size.y * .575), const Radius.circular(26)),
      Paint()..color = const Color(0xEE251044),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .29, size.y * .17, size.x * .42, size.y * .045), const Radius.circular(16)),
      Paint()..color = const Color(0xDD2B1450),
    );
    _text(canvas, 'STAGE ${session.stage} · ${session.route.length} DOORS', size.x * .31, size.y * .177, 14, const Color(0xFFFFFFFF), FontWeight.w800);

    final count = session.route.length;
    final usableH = size.y * .46;
    final rowH = (usableH / count).clamp(24.0, 58.0);
    final startY = size.y * .245;
    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = startY + i * rowH;
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .20, y, size.x * .60, rowH - 4),
        Radius.circular((rowH - 4) / 2),
      );
      canvas.drawRRect(rr, Paint()..color = isLeft ? const Color(0xFF3159D7) : const Color(0xFFE33E83));
      canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFFFD86D));
      final label = '${i + 1}   ${isLeft ? '← 왼쪽' : '오른쪽 →'}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: rowH.clamp(24, 44) * .42, fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((size.x - tp.width) / 2, y + (rowH - tp.height) / 2 - 2));
    }

    final remain = memorySeconds == null ? 0.0 : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .23, size.y * .735, size.x * .54, size.y * .036), const Radius.circular(18)),
      Paint()..color = const Color(0xCC24133F),
    );
    final timerText = memorySeconds == null ? '기억 완료 후 도전' : '기억 시간 ${remain.toStringAsFixed(1)}초';
    final tp = TextPainter(
      text: TextSpan(text: timerText, style: const TextStyle(color: Color(0xFFFFE38B), fontSize: 17, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, size.y * .741));
  }
}
