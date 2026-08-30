import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';

class IntroScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  late Sprite _bg;
  late TapZone _start;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay_clean.webp');
    _start = TapZone(onTap: game.startCurrentStage, triggerOnDown: true);
    add(_start);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _start
      ..size = Vector2(size.x * .74, size.y * .070)
      ..position = Vector2(size.x * .13, size.y * .905);
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    TextAlign align = TextAlign.center,
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? rect.width);
    final dx = rect.left + (rect.width - tp.width) / 2;
    final dy = rect.top + (rect.height - tp.height) / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawRealmMap(Canvas canvas, double topY, int stage) {
    final labels = ['인간 I', '인간 II', '인간 III', '초인', '기록', '신'];
    final x1 = size.x * .16;
    final x2 = size.x * .84;
    final y = topY + size.y * .029;
    final activeIndex = currentRealmIndex(stage);
    final step = (x2 - x1) / (labels.length - 1);

    canvas.drawLine(
      Offset(x1, y),
      Offset(x2, y),
      Paint()
        ..color = const Color(0x66E7C9FF)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < labels.length; i++) {
      final x = x1 + step * i;
      final done = i < activeIndex;
      final active = i == activeIndex;
      final radius = active ? 7.5 : 5.5;
      canvas.drawCircle(Offset(x, y), radius + 2.5, Paint()..color = const Color(0x66210C42));
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = done
              ? const Color(0xFFFFD867)
              : active
                  ? const Color(0xFF7E91FF)
                  : const Color(0xFF4A3369),
      );
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xCCFFFFFF),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            color: active ? const Color(0xFFFFEDB1) : const Color(0xFFD4C4F7),
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 52);
      tp.paint(canvas, Offset(x - tp.width / 2, y + 10));
    }
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    // Hide the original bottom hero area so the start button never clips a character silhouette.
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * .74, size.x, size.y * .26),
      Paint()..color = const Color(0x7A16082F),
    );

    final progress = game.progressStore.load();
    final currentStage = game.currentStage;
    final bestStage = progress.bestStage;
    final realm = stageRealmLabel(currentStage);

    final panelRect = Rect.fromLTWH(size.x * .05, size.y * .050, size.x * .90, size.y * .275);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF61B0C3A));
    canvas.drawRRect(
      panel.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x99FFD968),
    );

    _drawCenteredText(
      canvas,
      '몬스터 문 열기',
      Rect.fromLTWH(size.x * .12, size.y * .073, size.x * .76, size.y * .048),
      29,
      const Color(0xFFFFD968),
      FontWeight.w900,
    );
    _drawCenteredText(
      canvas,
      '공주가 몬스터에게 납치되었습니다.',
      Rect.fromLTWH(size.x * .10, size.y * .122, size.x * .80, size.y * .032),
      17,
      const Color(0xFFFFFFFF),
      FontWeight.w900,
    );
    _drawCenteredText(
      canvas,
      '비밀의 문을 기억하여 공주를 구하세요.',
      Rect.fromLTWH(size.x * .12, size.y * .165, size.x * .76, size.y * .034),
      15.5,
      const Color(0xFFFFE7A0),
      FontWeight.w800,
    );

    final statusRect = Rect.fromLTWH(size.x * .14, size.y * .224, size.x * .72, size.y * .054);
    final statusCard = RRect.fromRectAndRadius(statusRect, const Radius.circular(18));
    canvas.drawRRect(statusCard, Paint()..color = const Color(0xE029124C));
    canvas.drawRRect(
      statusCard,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0x66FFD968),
    );
    _drawCenteredText(
      canvas,
      '현재 진행  $realm  ·  STAGE $currentStage  ·  최고 ${bestStage == 0 ? '-' : bestStage}',
      statusRect,
      11.4,
      const Color(0xFFFFEDB0),
      FontWeight.w800,
    );

    _drawRealmMap(canvas, size.y * .255, currentStage);

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .905, size.x * .74, size.y * .070);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(26));
    canvas.drawRRect(
      btn,
      Paint()..color = _start.pressed ? const Color(0xFF5FD82C) : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFFFFF),
    );
    _drawCenteredText(canvas, '시작', btnRect, 22, const Color(0xFF102408), FontWeight.w900);
  }
}
