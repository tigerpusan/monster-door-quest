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
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay_final_clean_v2.png');
    _start = TapZone(onTap: _startGame, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    addAll([_start, _settings, _settingsClose, _settingsContinue]);
  }

  void _startGame() {
    if (_settingsOpen) return;
    game.startCurrentStage();
  }

  void _toggleSettings() {
    _settingsOpen = !_settingsOpen;
  }

  void _closeSettings() {
    _settingsOpen = false;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _start
      ..size = Vector2(size.x * .74, size.y * .072)
      ..position = Vector2(size.x * .13, size.y * .900);
    _settings
      ..size = Vector2(size.x * .17, size.y * .060)
      ..position = Vector2(size.x * .775, size.y * .020);
    _settingsClose
      ..size = Vector2(size.x * .10, size.y * .055)
      ..position = Vector2(size.x * .79, size.y * .165);
    _settingsContinue
      ..size = Vector2(size.x * .30, size.y * .068)
      ..position = Vector2(size.x * .35, size.y * .725);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    TextAlign align = TextAlign.center,
    double? maxWidth,
    double yOffset = 0,
    double height = 1.12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: height,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? rect.width);
    final dx = align == TextAlign.center ? rect.left + (rect.width - tp.width) / 2 : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
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
        ..color = const Color(0x88CBB6FF)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < labels.length; i++) {
      final x = x1 + step * i;
      final done = i < activeIndex;
      final active = i == activeIndex;
      final radius = active ? 8.0 : 6.0;
      canvas.drawCircle(Offset(x, y), radius + 2.2, Paint()..color = const Color(0x55200A40));
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = done
              ? const Color(0xFFFFD667)
              : active
                  ? const Color(0xFF8BA6FF)
                  : const Color(0xFF544075),
      );
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7
          ..color = const Color(0xEFFFFFFF),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 8.6,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            color: active ? const Color(0xFFFFEDB1) : const Color(0xFFD4C4F7),
            height: 1.05,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 54);
      tp.paint(canvas, Offset(x - tp.width / 2, y + 10));
    }
  }

  void _drawSettingsButton(Canvas canvas) {
    final rect = Rect.fromLTWH(size.x * .775, size.y * .020, size.x * .17, size.y * .060);
    final box = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(box, Paint()..color = const Color(0xDE16082F));
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xCCFFD86D),
    );
    _drawText(canvas, '⚙', rect, 21, const Color(0xFFFFEDB1), FontWeight.w900, yOffset: -1);
  }

  void _drawSettingsOverlay(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xB3000000));

    final panelRect = Rect.fromLTWH(size.x * .08, size.y * .12, size.x * .84, size.y * .66);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF01D0D41));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xCCFFD86D),
    );

    _drawText(canvas, '설정 · 게임 안내', Rect.fromLTWH(size.x * .18, size.y * .145, size.x * .52, size.y * .04), 23,
        const Color(0xFFFFDD7A), FontWeight.w900);
    _drawText(canvas, '✕', Rect.fromLTWH(size.x * .80, size.y * .155, size.x * .08, size.y * .03), 18,
        const Color(0xFFFFEDB1), FontWeight.w900);

    _drawText(
      canvas,
      '스토리\n몬스터에게 납치된 공주를 구하기 위해\n문의 순서를 기억하며 마지막 단계까지 도전하세요.',
      Rect.fromLTWH(size.x * .16, size.y * .235, size.x * .68, size.y * .12),
      14.5,
      const Color(0xFFFFFFFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.35,
    );
    _drawText(
      canvas,
      '플레이 방법\n1) 문 순서를 기억\n2) 순서대로 문 선택\n3) 성공 시 다음 스테이지 진입',
      Rect.fromLTWH(size.x * .16, size.y * .37, size.x * .68, size.y * .12),
      14.5,
      const Color(0xFFFFF2C7),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.35,
    );
    _drawText(
      canvas,
      '단계 설명\n인간 I~III : 좌우 문의 기본 기억\n초인 : 더 긴 순서와 복합 규칙\n기록 : 고난도 집중 구간\n신 : 최종 완성 단계',
      Rect.fromLTWH(size.x * .16, size.y * .505, size.x * .68, size.y * .15),
      14.2,
      const Color(0xFFE8DDFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.34,
    );
    _drawText(
      canvas,
      '실패 규칙\n실패 후 다시 도전하면 기본적으로 두 단계 전으로 돌아갑니다.',
      Rect.fromLTWH(size.x * .16, size.y * .655, size.x * .68, size.y * .07),
      13.8,
      const Color(0xFFFFD98D),
      FontWeight.w800,
      align: TextAlign.left,
      height: 1.30,
    );

    final continueRect = Rect.fromLTWH(size.x * .35, size.y * .725, size.x * .30, size.y * .068);
    final continueBox = RRect.fromRectAndRadius(continueRect, const Radius.circular(24));
    canvas.drawRRect(continueBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(
      continueBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = const Color(0xFFFFFFFF),
    );
    _drawText(canvas, '닫기', continueRect, 18, const Color(0xFF102408), FontWeight.w900, yOffset: -1);
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    canvas.drawRect(size.toRect(), Paint()..color = const Color(0x1609041D));
    _drawSettingsButton(canvas);

    final progress = game.progressStore.load();
    final currentStage = game.currentStage;
    final bestStage = progress.bestStage;
    final realm = stageRealmLabel(currentStage);

    final panelRect = Rect.fromLTWH(size.x * .05, size.y * .055, size.x * .90, size.y * .285);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel, Paint()..color = const Color(0xEA1A0B3B));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xCCFFD86C),
    );
    canvas.drawRRect(
      panel.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x44FFFFFF),
    );

    _drawText(
      canvas,
      '몬스터 문 열기',
      Rect.fromLTWH(size.x * .14, size.y * .078, size.x * .72, size.y * .046),
      29,
      const Color(0xFFFFD96C),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '공주가 몬스터에게 납치되었습니다.',
      Rect.fromLTWH(size.x * .10, size.y * .126, size.x * .80, size.y * .030),
      17,
      const Color(0xFFFFFFFF),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '비밀의 문을 기억하여 공주를 구하세요.',
      Rect.fromLTWH(size.x * .12, size.y * .166, size.x * .76, size.y * .032),
      16,
      const Color(0xFFFFE8A7),
      FontWeight.w800,
    );

    final statusRect = Rect.fromLTWH(size.x * .14, size.y * .228, size.x * .72, size.y * .052);
    final statusRRect = RRect.fromRectAndRadius(statusRect, const Radius.circular(18));
    canvas.drawRRect(statusRRect, Paint()..color = const Color(0xDE311553));
    canvas.drawRRect(
      statusRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0x99FFD968),
    );
    _drawText(
      canvas,
      '현재 진행  $realm  ·  STAGE $currentStage  ·  최고 ${bestStage == 0 ? '-' : bestStage}',
      statusRect,
      11.3,
      const Color(0xFFFFEDB0),
      FontWeight.w800,
    );

    _drawRealmMap(canvas, size.y * .258, currentStage);

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .900, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(
      btn,
      Paint()..color = _start.pressed ? const Color(0xFF57D429) : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFFFFF),
    );
    _drawText(canvas, '시작', btnRect, 23, const Color(0xFF102408), FontWeight.w900, yOffset: -1);

    if (_settingsOpen) {
      _drawSettingsOverlay(canvas);
    }
  }
}
