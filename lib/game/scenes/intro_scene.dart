import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/pixel_art_kit.dart';

class IntroScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  late Sprite _bg;
  late PixelArtKit _pixelArt;
  late TapZone _start;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsMusic;
  late TapZone _settingsReset;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/pixel_bg_base.png');
    _pixelArt = await PixelArtKit.load();
    _start = TapZone(onTap: _startGame, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([
      _start,
      _settings,
      _settingsClose,
      _settingsContinue,
      _settingsMusic,
      _settingsReset,
    ]);
  }

  void _startGame() {
    if (_settingsOpen) return;
    game.startCurrentStage();
  }

  void _toggleSettings() => _settingsOpen = !_settingsOpen;
  void _closeSettings() => _settingsOpen = false;

  void _toggleBgm() {
    if (!_settingsOpen) return;
    game.audioManager.bgmEnabled = !game.audioManager.bgmEnabled;
    if (game.audioManager.bgmEnabled) {
      game.audioManager.startBgm();
    } else {
      game.audioManager.stopBgm();
    }
  }

  Future<void> _resetChallenge() async {
    if (!_settingsOpen) return;
    await game.progressStore.saveCurrentStage(GameRules.initialStage);
    game.currentStage = GameRules.initialStage;
    _settingsOpen = false;
    game.goHome();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _start
      ..size = Vector2(size.x * .74, size.y * .072)
      ..position = Vector2(size.x * .13, size.y * .900);
    _settings
      ..size = Vector2(size.x * .145, size.y * .060)
      ..position = Vector2(size.x * .805, size.y * .022);
    _settingsClose
      ..size = Vector2(size.x * .09, size.y * .050)
      ..position = Vector2(size.x * .82, size.y * .090);
    _settingsMusic
      ..size = Vector2(size.x * .72, size.y * .060)
      ..position = Vector2(size.x * .14, size.y * .245);
    _settingsReset
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .13, size.y * .812);
    _settingsContinue
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .52, size.y * .812);
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
    final dx = align == TextAlign.center
        ? rect.left + (rect.width - tp.width) / 2
        : rect.left;
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
      canvas.drawCircle(Offset(x, y), radius + 2.2,
          Paint()..color = const Color(0x55200A40));
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
            color: active
                ? const Color(0xFFFFEDB1)
                : const Color(0xFFD4C4F7),
            height: 1.05,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 54);
      tp.paint(canvas, Offset(x - tp.width / 2, y + 10));
    }
  }

  void _drawSettingsOverlay(Canvas canvas) {
    final p = game.progressStore.load();
    GameHelpOverlay.draw(
      canvas,
      size.x,
      size.y,
      currentStage: game.currentStage,
      bestStage: p.bestStage,
      bgmEnabled: game.audioManager.bgmEnabled,
    );
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);
    _pixelArt.renderDecor(canvas, size, dense: true);
    _pixelArt.renderDoorPair(canvas, size, top: .48, scale: .30);
    _pixelArt.renderHero(canvas, size, x: .39, y: .67, scale: .22);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    final progress = game.progressStore.load();
    final currentStage = game.currentStage;
    final bestStage = progress.bestStage;
    final realm = stageRealmLabel(currentStage);

    // Keep the intro card fully below the gear button so their borders never cross.
    final panelRect = Rect.fromLTWH(size.x * .055, size.y * .122, size.x * .86, size.y * .255);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF7FFF7E7));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFF346BB4),
    );
    canvas.drawRRect(
      panel.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x99FFFFFF),
    );

    _drawText(
      canvas,
      '몬스터 문 열기',
      Rect.fromLTWH(size.x * .14, size.y * .140, size.x * .68, size.y * .044),
      29,
      const Color(0xFF174B87),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '공주가 몬스터에게 납치되었습니다.',
      Rect.fromLTWH(size.x * .10, size.y * .192, size.x * .76, size.y * .030),
      17,
      const Color(0xFF17345B),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '비밀의 문을 기억하여 공주를 구하세요.',
      Rect.fromLTWH(size.x * .11, size.y * .229, size.x * .75, size.y * .032),
      16,
      const Color(0xFF2D658E),
      FontWeight.w800,
    );

    final statusRect = Rect.fromLTWH(size.x * .13, size.y * .281, size.x * .70, size.y * .048);
    final statusRRect = RRect.fromRectAndRadius(statusRect, const Radius.circular(18));
    canvas.drawRRect(statusRRect, Paint()..color = const Color(0xFFF0FAFF));
    canvas.drawRRect(
      statusRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF68A4D7),
    );
    _drawText(
      canvas,
      '현재 진행  $realm  ·  STAGE $currentStage  ·  최고 ${bestStage == 0 ? '-' : bestStage}',
      statusRect,
      11.3,
      const Color(0xFF235A86),
      FontWeight.w800,
    );
    _drawRealmMap(canvas, size.y * .311, currentStage);

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .900, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(
      btn,
      Paint()..color = _start.pressed ? const Color(0xFF49C755) : const Color(0xFF76E56D),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF17345B),
    );
    _drawText(canvas, '시작', btnRect, 23, const Color(0xFF12341B), FontWeight.w900,
        yOffset: -1);

    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
