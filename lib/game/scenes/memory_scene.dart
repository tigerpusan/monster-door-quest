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
  late TapZone _home;
  double elapsed = 0;
  bool _transitioned = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay.webp');
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _home = TapZone(onTap: game.goHome, triggerOnDown: true);
    addAll([_ready, _home]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;

    // Keep the HOME hit-zone fully outside the main memory panel so the
    // outline can never cross the panel border.
    _home
      ..size = Vector2(size.x * .145, size.y * .043)
      ..position = Vector2(size.x * .815, size.y * .014)
      ..priority = 1100;

    _ready
      ..size = Vector2(size.x * .76, size.y * .066)
      ..position = Vector2(size.x * .12, size.y * .906)
      ..priority = 1000;
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
    FontWeight weight, {
    double maxWidthFactor = .88,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fs,
          fontWeight: weight,
          color: color,
          height: 1.05,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x * maxWidthFactor);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  void _renderHomeButton(Canvas canvas) {
    final home = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .815, size.y * .014, size.x * .145, size.y * .043),
      const Radius.circular(16),
    );
    canvas.drawRRect(home, Paint()..color = const Color(0xE51A0B35));
    canvas.drawRRect(
      home,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xCCFFD86D),
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '처음',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFEDB1),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.x * .8875 - tp.width / 2, size.y * .026),
    );
  }

  @override
  void render(Canvas canvas) {
    // Decorative background stays visible only around the edge. The memory
    // panel itself is intentionally opaque, so baked hero/door art can never
    // appear cut off between the timer and CTA.
    _bg.render(
      canvas,
      position: Vector2(0, -size.y * .035),
      size: Vector2(size.x, size.y * 1.035),
    );

    final mainPanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .04, size.y * .066, size.x * .92, size.y * .91),
      const Radius.circular(30),
    );
    canvas.drawRRect(mainPanel, Paint()..color = const Color(0xFC1D0B3A));
    canvas.drawRRect(
      mainPanel.deflate(size.x * .018),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xA0FFD76E),
    );

    _renderHomeButton(canvas);

    _center(
      canvas,
      '문 순서를 기억하세요',
      size.y * .095,
      27,
      const Color(0xFFFFD96C),
      FontWeight.w900,
    );
    _center(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      size.y * .143,
      14,
      const Color(0xFFECE2FF),
      FontWeight.w800,
    );

    final count = session.route.length;

    // Fixed header/footer reservation prevents stage 10+ rows from pushing
    // the timer into the hero/button area.
    final startY = size.y * .195;
    final rowsBottom = size.y * .760;
    final gap = size.y * .004;
    final available = rowsBottom - startY;
    final rawRowH = available / count;
    final rowH = rawRowH.clamp(27.0, 54.0);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = startY + i * rowH;
      final visualH = (rowH - gap).clamp(23.0, 52.0);
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .17, y, size.x * .66, visualH),
        Radius.circular(visualH / 2),
      );

      canvas.drawRRect(
        rr,
        Paint()
          ..color = isLeft
              ? const Color(0xFF3159D7)
              : const Color(0xFFE33E83),
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
            fontSize: visualH.clamp(23, 46) * .42,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          (size.x - tp.width) / 2,
          y + (visualH - tp.height) / 2 - 1,
        ),
      );
    }

    final remain = memorySeconds == null
        ? 0.0
        : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null
        ? '준비되면 바로 도전하세요'
        : '기억 시간 ${remain.toStringAsFixed(1)}초';

    final timerPill = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .27, size.y * .795, size.x * .46, size.y * .050),
      const Radius.circular(20),
    );
    canvas.drawRRect(timerPill, Paint()..color = const Color(0xFF2A1452));
    canvas.drawRRect(
      timerPill,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x66FFD86D),
    );
    _center(
      canvas,
      timerText,
      size.y * .809,
      17,
      const Color(0xFFFFE38B),
      FontWeight.w900,
      maxWidthFactor: .42,
    );

    // Dedicated CTA zone: no baked hero or background art behind it.
    final ctaZone = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .085, size.y * .875, size.x * .83, size.y * .095),
      const Radius.circular(28),
    );
    canvas.drawRRect(ctaZone, Paint()..color = const Color(0xFF1D0B3A));

    final btn = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .12, size.y * .906, size.x * .76, size.y * .066),
      const Radius.circular(26),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..color = _ready.pressed
            ? const Color(0xFF58D22B)
            : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = const Color(0xFFFFFFFF),
    );
    _center(
      canvas,
      _ready.pressed ? '도전!' : '✨ 기억 완료 · 도전! ✨',
      size.y * .925,
      19,
      const Color(0xFF12230B),
      FontWeight.w900,
    );
  }
}
