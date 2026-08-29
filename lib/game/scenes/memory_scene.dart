import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';

class MemoryScene extends PositionComponent
    with HasGameReference<MonsterDoorGame> {
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
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
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

  void _center(
    Canvas canvas,
    String text,
    double y,
    double fs,
    Color color,
    FontWeight weight,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fs, fontWeight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x * .88);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    // Solid content panel removes every baked-in title/list from the mockup.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .07, size.y * .055, size.x * .86, size.y * .75),
        const Radius.circular(30),
      ),
      Paint()..color = const Color(0xF4261047),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .085, size.y * .07, size.x * .83, size.y * .72),
        const Radius.circular(26),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x88FFD76E),
    );

    _center(
      canvas,
      '문 순서를 기억하세요',
      size.y * .085,
      28,
      const Color(0xFFFFD96C),
      FontWeight.w900,
    );
    _center(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      size.y * .14,
      14,
      const Color(0xFFECE2FF),
      FontWeight.w800,
    );

    final count = session.route.length;
    final usableH = size.y * .50;
    final rowH = (usableH / count).clamp(22.0, 54.0);
    final startY = size.y * .205;
    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = startY + i * rowH;
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .17, y, size.x * .66, rowH - 4),
        Radius.circular((rowH - 4) / 2),
      );
      canvas.drawRRect(
        rr,
        Paint()..color = isLeft ? const Color(0xFF3159D7) : const Color(0xFFE33E83),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFD86D),
      );
      final label = '${i + 1}   ${isLeft ? '← 왼쪽' : '오른쪽 →'}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: rowH.clamp(22, 42) * .42,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((size.x - tp.width) / 2, y + (rowH - tp.height) / 2 - 2),
      );
    }

    final remain = memorySeconds == null
        ? 0.0
        : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null
        ? '준비되면 바로 도전하세요'
        : '기억 시간 ${remain.toStringAsFixed(1)}초';
    _center(
      canvas,
      timerText,
      size.y * .745,
      17,
      const Color(0xFFFFE38B),
      FontWeight.w900,
    );

    final btn = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .12, size.y * .84, size.x * .76, size.y * .075),
      const Radius.circular(25),
    );
    canvas.drawRRect(
      btn,
      Paint()..color = _ready.pressed ? const Color(0xFF58D22B) : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFFFFFFFF),
    );
    _center(
      canvas,
      _ready.pressed ? '도전!' : '✨ 기억 완료 · 도전! ✨',
      size.y * .857,
      22,
      const Color(0xFF12230B),
      FontWeight.w900,
    );
  }
}
