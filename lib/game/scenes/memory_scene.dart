import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
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
    _bg = await Sprite.load('ui/gameplay_clean.webp');
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _home = TapZone(onTap: game.goHome, triggerOnDown: true);
    addAll([_ready, _home]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _ready
      ..size = Vector2(size.x * .74, size.y * .070)
      ..position = Vector2(size.x * .13, size.y * .895);
    _home
      ..size = Vector2(size.x * .16, size.y * .052)
      ..position = Vector2(size.x * .79, size.y * .020);
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
      if (elapsed >= memorySeconds! && isMounted) {
        _goDoor();
      }
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: 1.12,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth ?? rect.width);
    final dx = rect.left + (rect.width - tp.width) / 2;
    final dy = rect.top + (rect.height - tp.height) / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    // soft full-screen tint for consistent contrast
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0x220D0622),
    );

    final homeRect = Rect.fromLTWH(size.x * .79, size.y * .020, size.x * .16, size.y * .052);
    final homeBox = RRect.fromRectAndRadius(homeRect, const Radius.circular(18));
    canvas.drawRRect(homeBox, Paint()..color = const Color(0xD016082F));
    canvas.drawRRect(
      homeBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0x99FFD86D),
    );
    _drawCenteredText(canvas, '처음', homeRect, 14, const Color(0xFFFFEDB1), FontWeight.w900);

    final panelRect = Rect.fromLTWH(size.x * .045, size.y * .085, size.x * .91, size.y * .775);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF2261046));
    canvas.drawRRect(
      panel.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x88FFD76E),
    );

    _drawCenteredText(
      canvas,
      '문 순서를 기억하세요',
      Rect.fromLTWH(size.x * .10, size.y * .108, size.x * .80, size.y * .048),
      28,
      const Color(0xFFFFD96C),
      FontWeight.w900,
    );
    _drawCenteredText(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      Rect.fromLTWH(size.x * .18, size.y * .151, size.x * .64, size.y * .024),
      14,
      const Color(0xFFECE2FF),
      FontWeight.w800,
    );

    final count = session.route.length;
    final listTop = size.y * .205;
    final listBottom = size.y * .675;
    final listHeight = listBottom - listTop;
    final gap = count >= 14 ? 4.0 : count >= 10 ? 6.0 : 8.0;
    final rowHeight = ((listHeight - gap * (count - 1)) / count).clamp(24.0, 58.0);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = listTop + i * (rowHeight + gap);
      final rowRect = Rect.fromLTWH(size.x * .17, y, size.x * .66, rowHeight);
      final rr = RRect.fromRectAndRadius(rowRect, Radius.circular(rowHeight / 2));
      canvas.drawRRect(
        rr,
        Paint()..color = isLeft ? const Color(0xFF365BDA) : const Color(0xFFE34389),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFD86D),
      );
      final fontSize = (rowHeight * (count >= 14 ? .42 : .48)).clamp(14.0, 25.0);
      _drawCenteredText(
        canvas,
        '${i + 1}   ${isLeft ? '← 왼쪽' : '오른쪽 →'}',
        rowRect,
        fontSize,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
    }

    final remain = memorySeconds == null
        ? 0.0
        : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null
        ? '준비되면 바로 도전하세요'
        : '기억 시간 ${remain.toStringAsFixed(1)}초';
    final timerRect = Rect.fromLTWH(size.x * .27, size.y * .735, size.x * .46, size.y * .055);
    final timerPill = RRect.fromRectAndRadius(timerRect, const Radius.circular(22));
    canvas.drawRRect(timerPill, Paint()..color = const Color(0xB024114A));
    canvas.drawRRect(
      timerPill,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x88FFD96A),
    );
    _drawCenteredText(canvas, timerText, timerRect, 17, const Color(0xFFFFE38B), FontWeight.w900);

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .895, size.x * .74, size.y * .070);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(26));
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
    _drawCenteredText(
      canvas,
      _ready.pressed ? '도전!' : '✨ 기억 완료 · 도전! ✨',
      btnRect,
      19,
      const Color(0xFF12230B),
      FontWeight.w900,
    );
  }
}
