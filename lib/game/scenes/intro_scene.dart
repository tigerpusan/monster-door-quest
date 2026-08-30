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
    _bg = await Sprite.load('ui/gameplay.webp');
    _start = TapZone(onTap: game.startCurrentStage, triggerOnDown: true);
    add(_start);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _start
      ..size = Vector2(size.x * .74, size.y * .062)
      ..position = Vector2(size.x * .13, size.y * .925);
  }

  void _centerText(
    Canvas canvas,
    String text,
    double y,
    double fs,
    Color color,
    FontWeight weight, {
    double maxWidthFactor = .86,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fs,
          fontWeight: weight,
          color: color,
          height: 1.18,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x * maxWidthFactor);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  void _drawRealmMap(Canvas canvas, double topY, int stage) {
    final labels = ['인간 I', '인간 II', '인간 III', '초인', '기록', '신'];
    final x1 = size.x * .16;
    final x2 = size.x * .84;
    final y = topY + size.y * .028;
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
    _bg.render(
      canvas,
      position: Vector2(0, -size.y * .055),
      size: Vector2(size.x, size.y * 1.055),
    );

    // Cover the baked title area, but stop high enough that the door sign labels remain visible.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y * .185),
      Paint()..color = const Color(0xFF16082F),
    );

    final progress = game.progressStore.load();
    final currentStage = game.currentStage;
    final bestStage = progress.bestStage;
    final realm = stageRealmLabel(currentStage);

    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .05, size.y * .038, size.x * .90, size.y * .275),
      const Radius.circular(28),
    );
    canvas.drawRRect(panel, Paint()..color = const Color(0xF61B0C3A));
    canvas.drawRRect(
      panel.deflate(12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x99FFD968),
    );

    _centerText(canvas, '몬스터 문 열기', size.y * .061, 29, const Color(0xFFFFD968), FontWeight.w900);
    _centerText(canvas, '공주가 몬스터에게 납치되었습니다!', size.y * .109, 17, const Color(0xFFFFFFFF), FontWeight.w900);
    _centerText(canvas, '열릴 문을 기억하세요.', size.y * .156, 15.2,
        const Color(0xFFF4EFFF), FontWeight.w800, maxWidthFactor: .78);
    _centerText(canvas, '용사의 기억력이 공주를 구합니다.', size.y * .191, 15.8,
        const Color(0xFFFFE7A0), FontWeight.w800);
    _centerText(canvas, '① 기억하기   ② 문 열기   ③ 틀리면 몬스터 출현', size.y * .228, 12.5,
        const Color(0xFFDCCBFF), FontWeight.w700, maxWidthFactor: .80);

    final statusCard = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .14, size.y * .255, size.x * .72, size.y * .052),
      const Radius.circular(18),
    );
    canvas.drawRRect(statusCard, Paint()..color = const Color(0xE029124C));
    canvas.drawRRect(
      statusCard,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0x66FFD968),
    );
    _centerText(
      canvas,
      '현재 진행  $realm  ·  STAGE $currentStage  ·  최고 ${bestStage == 0 ? '-' : bestStage}',
      size.y * .270,
      11.4,
      const Color(0xFFFFEDB0),
      FontWeight.w800,
      maxWidthFactor: .68,
    );

    _drawRealmMap(canvas, size.y * .285, currentStage);

    final btn = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .13, size.y * .925, size.x * .74, size.y * .062),
      const Radius.circular(24),
    );
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
    _centerText(canvas, '시작', size.y * .939, 22, const Color(0xFF102408), FontWeight.w900);
  }
}
