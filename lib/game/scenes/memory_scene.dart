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
    _bg = await Sprite.load('ui/gameplay_rebuild.png');
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _home = TapZone(onTap: game.goHome, triggerOnDown: true);
    addAll([_ready, _home]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _ready
      ..size = Vector2(size.x * .74, size.y * .072)
      ..position = Vector2(size.x * .13, size.y * .894);
    _home
      ..size = Vector2(size.x * .17, size.y * .060)
      ..position = Vector2(size.x * .775, size.y * .020);
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
    double yOffset = 0,
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
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    canvas.drawRect(size.toRect(), Paint()..color = const Color(0x1809041D));

    final homeRect = Rect.fromLTWH(size.x * .775, size.y * .020, size.x * .17, size.y * .060);
    final homeBox = RRect.fromRectAndRadius(homeRect, const Radius.circular(22));
    canvas.drawRRect(homeBox, Paint()..color = const Color(0xDE16082F));
    canvas.drawRRect(
      homeBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xCCFFD86D),
    );
    _drawCenteredText(canvas, '처음', homeRect, 16, const Color(0xFFFFEDB1), FontWeight.w900, yOffset: -1);

    final panelRect = Rect.fromLTWH(size.x * .05, size.y * .090, size.x * .90, size.y * .770);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0xEE220F46));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xCCFFD86D),
    );
    canvas.drawRRect(
      panel.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x40FFFFFF),
    );

    _drawCenteredText(
      canvas,
      '문 순서를 기억하세요',
      Rect.fromLTWH(size.x * .10, size.y * .118, size.x * .80, size.y * .046),
      28,
      const Color(0xFFFFD96C),
      FontWeight.w900,
    );
    _drawCenteredText(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      Rect.fromLTWH(size.x * .20, size.y * .162, size.x * .60, size.y * .024),
      14.5,
      const Color(0xFFF0E7FF),
      FontWeight.w800,
    );

    final count = session.route.length;
    final listTop = size.y * .212;
    final listBottom = size.y * .666;
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
        yOffset: -0.5,
      );
    }

    final remain = memorySeconds == null
        ? 0.0
        : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null
        ? '준비되면 바로 도전하세요'
        : '기억 시간 ${remain.toStringAsFixed(1)}초';
    final timerRect = Rect.fromLTWH(size.x * .29, size.y * .724, size.x * .42, size.y * .054);
    final timerPill = RRect.fromRectAndRadius(timerRect, const Radius.circular(22));
    canvas.drawRRect(timerPill, Paint()..color = const Color(0xD42A124C));
    canvas.drawRRect(
      timerPill,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..color = const Color(0xAAFFD96A),
    );
    _drawCenteredText(canvas, timerText, timerRect, 16.5, const Color(0xFFFFE38B), FontWeight.w900, yOffset: -0.5);

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .894, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(
      btn,
      Paint()..color = _ready.pressed ? const Color(0xFF58D22B) : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = const Color(0xFFFFFFFF),
    );
    _drawCenteredText(
      canvas,
      _ready.pressed ? '도전!' : '✨ 기억 완료 · 도전! ✨',
      btnRect,
      20,
      const Color(0xFF12230B),
      FontWeight.w900,
      yOffset: -1,
    );
  }
}
