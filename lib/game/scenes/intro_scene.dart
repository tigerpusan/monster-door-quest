import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';

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
      ..position = Vector2(size.x * .80, size.y * .135);
    _settingsContinue
      ..size = Vector2(size.x * .32, size.y * .060)
      ..position = Vector2(size.x * .34, size.y * .790);
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
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);
  }

  void _drawSettingsOverlay(Canvas canvas) {
    GameHelpOverlay.draw(canvas, size.x, size.y, showHome: false);
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
