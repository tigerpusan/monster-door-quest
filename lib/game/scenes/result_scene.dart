import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../core/game_rules.dart';
import '../components/tap_zone.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/pixel_art_kit.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage, required this.elapsedSeconds});

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late PixelArtKit _pixelArt;
  late TapZone _primary;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsMusic;
  late TapZone _settingsReset;
  bool _handled = false;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _pixelArt = await PixelArtKit.load();
    _primary = TapZone(onTap: _goNext, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([_primary, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
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

  Future<void> _retryWithPenalty() async {
    final dynamic g = game;
    final targetStage = stage <= 2 ? 1 : stage - 2;
    try {
      await g.retryWithPenalty(targetStage: targetStage, penaltySteps: 2);
      return;
    } catch (_) {}
    try {
      await g.retryFromStage(targetStage);
      return;
    } catch (_) {}
    try {
      g.currentStage = targetStage;
      await g.startCurrentStage();
      return;
    } catch (_) {}
    await game.retryCurrentStage();
  }

  void _goNext() {
    if (_settingsOpen || _handled) return;
    _handled = true;
    if (clear) {
      unawaited(game.advanceAfterClear());
    } else {
      unawaited(_retryWithPenalty());
    }
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
    _placeZone(_primary,
        Rect.fromLTWH(size.x * .11, clear ? size.y * .842 : size.y * .835,
            size.x * .78, clear ? size.y * .084 : size.y * .10),
        priority: 1000);
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 1100);
    _placeZone(_settingsClose, GameHelpOverlay.closeRect(size.x, size.y), priority: 2001);
    _placeZone(_settingsMusic, GameHelpOverlay.musicRect(size.x, size.y), priority: 2001);
    _placeZone(_settingsReset, GameHelpOverlay.resetRect(size.x, size.y), priority: 2001);
    _placeZone(_settingsContinue, GameHelpOverlay.continueRect(size.x, size.y), priority: 2001);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    double yOffset = 0,
    TextAlign align = TextAlign.center,
    double height = 1.12,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color, height: height)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: rect.width);
    final dx = align == TextAlign.center ? rect.left + (rect.width - tp.width) / 2 : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
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

  void _drawClear(Canvas canvas) {
    _pixelArt.renderClearParty(canvas, size);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    final titleRect = Rect.fromLTWH(size.x * .12, size.y * .105, size.x * .76, size.y * .080);
    _drawText(canvas, '스테이지 클리어!', titleRect.shift(const Offset(2, 3)), 32,
        const Color(0xFF0E3B73), FontWeight.w900);
    _drawText(canvas, '스테이지 클리어!', titleRect, 32, const Color(0xFF1B5596), FontWeight.w900);

    final milestoneRect = Rect.fromLTWH(size.x * .09, size.y * .195, size.x * .82, size.y * .044);
    final milestone = RRect.fromRectAndRadius(milestoneRect, const Radius.circular(22));
    canvas.drawRRect(milestone.shift(const Offset(0, 3)), Paint()..color = const Color(0x330B3768));
    canvas.drawRRect(milestone, Paint()..color = const Color(0xF8FFF7E5));
    canvas.drawRRect(milestone, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.6..color = const Color(0xFF5A8FC3));
    _drawText(canvas, '공주에게 한 걸음 더 가까워졌습니다.', milestoneRect, 15.8,
        const Color(0xFF244E76), FontWeight.w900);

    final cardRect = Rect.fromLTWH(size.x * .10, size.y * .684, size.x * .80, size.y * .136);
    final card = RRect.fromRectAndRadius(cardRect, const Radius.circular(30));
    canvas.drawRRect(card.shift(const Offset(0, 4)), Paint()..color = const Color(0x330B3768));
    canvas.drawRRect(card, Paint()..color = const Color(0xFAFFF4DC));
    canvas.drawRRect(card, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.4..color = const Color(0xFF3C78B7));
    canvas.drawRRect(card.deflate(7), Paint()..style = PaintingStyle.stroke..strokeWidth = .9..color = const Color(0x77FFFFFF));

    final timeLine = Rect.fromLTWH(cardRect.left + 18, cardRect.top + cardRect.height * .14,
        cardRect.width - 36, cardRect.height * .38);
    final realmLine = Rect.fromLTWH(cardRect.left + 18, cardRect.top + cardRect.height * .55,
        cardRect.width - 36, cardRect.height * .28);
    _drawText(canvas, '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초', timeLine, 27,
        const Color(0xFFA15C00), FontWeight.w900);
    _drawText(canvas, '${stageRealmLabel(stage)}  ·  STAGE $stage 완료', realmLine, 16.7,
        const Color(0xFF315B7E), FontWeight.w900);

    final primaryRect = Rect.fromLTWH(size.x * .11, size.y * .842, size.x * .78, size.y * .084);
    final primary = RRect.fromRectAndRadius(primaryRect, const Radius.circular(30));
    canvas.drawRRect(primary.shift(const Offset(0, 4)), Paint()..color = const Color(0x44246016));
    canvas.drawRRect(primary, Paint()..color = _primary.pressed || _handled ? const Color(0xFF49C755) : const Color(0xFF74E64B));
    canvas.drawRRect(primary, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFF17345B));
    _drawText(canvas, '✦  다음 스테이지  ✦', primaryRect, 23, const Color(0xFF12341B), FontWeight.w900, yOffset: -1);
  }

  void _drawFail(Canvas canvas) {
    _pixelArt.renderFailWorld(canvas, size);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);
    _drawText(canvas, '아쉬워요!', Rect.fromLTWH(size.x * .18, size.y * .11, size.x * .64, size.y * .08),
        30, const Color(0xFF174B87), FontWeight.w900);

    final info = Rect.fromLTWH(size.x * .08, size.y * .675, size.x * .84, size.y * .105);
    final box = RRect.fromRectAndRadius(info, const Radius.circular(25));
    canvas.drawRRect(box, Paint()..color = const Color(0xF8FFF1E7));
    canvas.drawRRect(box, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFD16B59));
    _drawText(canvas, '문 뒤에서 몬스터가 나타났습니다.\n두 단계 전으로 돌아가 다시 도전합니다.',
        info.deflate(14), 14.2, const Color(0xFF7C3A32), FontWeight.w900, height: 1.32);

    final retryRect = Rect.fromLTWH(size.x * .11, size.y * .835, size.x * .78, size.y * .10);
    final retry = RRect.fromRectAndRadius(retryRect, const Radius.circular(32));
    canvas.drawRRect(retry.shift(const Offset(0, 4)), Paint()..color = const Color(0x44246016));
    canvas.drawRRect(retry, Paint()..color = _primary.pressed || _handled ? const Color(0xFF49C755) : const Color(0xFF76E56D));
    canvas.drawRRect(retry, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFF17345B));
    _drawText(canvas, _handled ? '다시 시작 중...' : '다시 도전', retryRect, 24,
        const Color(0xFF12341B), FontWeight.w900);
  }

  @override
  void render(Canvas canvas) {
    if (clear) {
      _drawClear(canvas);
    } else {
      _drawFail(canvas);
    }
    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
