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
    _pixelArt = await PixelArtKit.load();
    _start = TapZone(onTap: _startGame, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([_start, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
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

  void _placeZone(TapZone zone, Rect r, {int? priority}) {
    zone
      ..size = Vector2(r.width, r.height)
      ..position = Vector2(r.left, r.top);
    if (priority != null) zone.priority = priority;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _placeZone(_start, Rect.fromLTWH(size.x * .13, size.y * .900, size.x * .74, size.y * .072));
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _placeZone(_settingsClose, GameHelpOverlay.closeRect(size.x, size.y), priority: 2200);
    _placeZone(_settingsMusic, GameHelpOverlay.musicRect(size.x, size.y), priority: 2200);
    _placeZone(_settingsReset, GameHelpOverlay.resetRect(size.x, size.y), priority: 2200);
    _placeZone(_settingsContinue, GameHelpOverlay.continueRect(size.x, size.y), priority: 2200);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    TextAlign align = TextAlign.center,
    double yOffset = 0,
    double height = 1.12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color, height: height),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: rect.width);
    final dx = align == TextAlign.center ? rect.left + (rect.width - tp.width) / 2 : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawLogo(Canvas canvas) {
    final r = Rect.fromLTWH(size.x * .11, size.y * .102, size.x * .78, size.y * .072);
    _drawText(canvas, '문대작전!', r.shift(const Offset(2.5, 3.0)), 35,
        const Color(0xFF0E3B73), FontWeight.w900);
    _drawText(canvas, '문대작전!', r, 35, const Color(0xFFFFB92E), FontWeight.w900);
  }

  void _drawRealmMap(Canvas canvas, double topY, int stage) {
    final labels = ['인간 I', '인간 II', '인간 III', '초인 I', '초인 II', '초인 III', '신'];
    final x1 = size.x * .14;
    final x2 = size.x * .86;
    final y = topY + size.y * .018;
    final activeIndex = currentRealmIndex(stage);
    final step = (x2 - x1) / (labels.length - 1);

    canvas.drawLine(
      Offset(x1, y),
      Offset(x2, y),
      Paint()..color = const Color(0xFFB8A9E6)..strokeWidth = 3..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < labels.length; i++) {
      final x = x1 + step * i;
      final done = i < activeIndex;
      final active = i == activeIndex;
      final radius = active ? 8.4 : 6.5;
      canvas.drawCircle(Offset(x, y + 2), radius + 3, Paint()..color = const Color(0x330B3768));
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = done ? const Color(0xFFFFD052) : active ? const Color(0xFF4F91FF) : const Color(0xFF53456B),
      );
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = const Color(0xFFFFFFFF),
      );
      _drawText(
        canvas,
        labels[i],
        Rect.fromLTWH(x - size.x * .062, y + 11, size.x * .124, size.y * .026),
        8.7,
        active ? const Color(0xFF2863A4) : const Color(0xFF6D5C9B),
        active ? FontWeight.w900 : FontWeight.w800,
      );
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
      pixelArt: _pixelArt,
    );
  }

  @override
  void render(Canvas canvas) {
    _pixelArt.renderIntroWorld(canvas, size);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    final progress = game.progressStore.load();
    final currentStage = game.currentStage;
    final bestStage = progress.bestStage;
    final realm = stageRealmLabel(currentStage);

    final panelRect = Rect.fromLTWH(size.x * .055, size.y * .086, size.x * .89, size.y * .292);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel.shift(const Offset(0, 5)), Paint()..color = const Color(0x330B3768));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF9FFF8E7));
    canvas.drawRRect(panel, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.6..color = const Color(0xFF2E6CB1));
    canvas.drawRRect(panel.deflate(9), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = const Color(0x66FFFFFF));

    _drawLogo(canvas);
    _drawText(
      canvas,
      '문 순서를 기억해 공주를 구하세요!',
      Rect.fromLTWH(size.x * .11, size.y * .176, size.x * .78, size.y * .030),
      17.2,
      const Color(0xFF173F70),
      FontWeight.w900,
    );

    final statusRect = Rect.fromLTWH(size.x * .12, size.y * .223, size.x * .76, size.y * .050);
    final statusRRect = RRect.fromRectAndRadius(statusRect, const Radius.circular(18));
    canvas.drawRRect(statusRRect, Paint()..color = const Color(0xFFF0FAFF));
    canvas.drawRRect(statusRRect, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.6..color = const Color(0xFF68A4D7));
    _drawText(
      canvas,
      '현재 진행  $realm   ·   STAGE $currentStage   ·   최고 ${bestStage == 0 ? '-' : bestStage}',
      statusRect,
      11.2,
      const Color(0xFF235A86),
      FontWeight.w900,
    );
    _drawRealmMap(canvas, size.y * .282, currentStage);

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .900, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(btn.shift(const Offset(0, 4)), Paint()..color = const Color(0x44246016));
    canvas.drawRRect(btn, Paint()..color = _start.pressed ? const Color(0xFF4FCB50) : const Color(0xFF79EA62));
    canvas.drawRRect(btn, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFF174B87));
    _drawText(canvas, '✦  시작  ✦', btnRect, 23, const Color(0xFF10341B), FontWeight.w900, yOffset: -1);

    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
