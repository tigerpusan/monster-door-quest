import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../core/game_rules.dart';
import '../components/tap_zone.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage, required this.elapsedSeconds});

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late Sprite _bg;
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
    _bg = await Sprite.load(clear ? 'ui/stage_clear_final_clean_v2.png' : 'ui/monster_attack.webp');
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

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _primary
      ..size = Vector2(size.x * .78, clear ? size.y * .086 : size.y * .10)
      ..position = Vector2(size.x * .11, clear ? size.y * .836 : size.y * .835)
      ..priority = 1000;
    _settings
      ..size = Vector2(size.x * .145, size.y * .060)
      ..position = Vector2(size.x * .805, size.y * .022)
      ..priority = 1100;
    _settingsClose
      ..size = Vector2(size.x * .09, size.y * .050)
      ..position = Vector2(size.x * .82, size.y * .090)
      ..priority = 2001;
    _settingsMusic
      ..size = Vector2(size.x * .72, size.y * .060)
      ..position = Vector2(size.x * .14, size.y * .245)
      ..priority = 2001;
    _settingsReset
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .13, size.y * .812)
      ..priority = 2001;
    _settingsContinue
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .52, size.y * .812)
      ..priority = 2001;
  }

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    double? maxWidth,
    double yOffset = 0,
    TextAlign align = TextAlign.center,
    double height = 1.12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color, height: height),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? rect.width);
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
    );
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    if (clear) {
      // Optical lift: keep the message between the clear title and the sword tip.
      final milestoneRect = Rect.fromLTWH(size.x * .09, size.y * .272, size.x * .82, size.y * .044);
      final milestone = RRect.fromRectAndRadius(milestoneRect, const Radius.circular(22));
      canvas.drawRRect(milestone, Paint()..color = const Color(0xA8251247));
      canvas.drawRRect(milestone, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0x88FFD96A));
      _drawText(
        canvas,
        '공주에게 한 걸음 더 가까워졌습니다.',
        milestoneRect,
        15.5,
        const Color(0xFFF6EDFF),
        FontWeight.w800,
      );

      // One result card only. Text is vertically balanced inside the same card.
      final cardRect = Rect.fromLTWH(size.x * .10, size.y * .690, size.x * .80, size.y * .128);
      final card = RRect.fromRectAndRadius(cardRect, const Radius.circular(30));
      canvas.drawRRect(card, Paint()..color = const Color(0xEC241046));
      canvas.drawRRect(card, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.4..color = const Color(0xFFFFD86D));

      _drawText(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        Rect.fromLTWH(cardRect.left + 20, cardRect.top + 18, cardRect.width - 40, 44),
        26,
        const Color(0xFFFFE08A),
        FontWeight.w900,
      );
      _drawText(
        canvas,
        '${stageRealmLabel(stage)}  ·  STAGE $stage 완료',
        Rect.fromLTWH(cardRect.left + 20, cardRect.top + 72, cardRect.width - 40, 34),
        17.4,
        const Color(0xFFE7DBFF),
        FontWeight.w800,
      );

      final primaryRect = Rect.fromLTWH(size.x * .11, size.y * .842, size.x * .78, size.y * .084);
      final primary = RRect.fromRectAndRadius(primaryRect, const Radius.circular(30));
      canvas.drawRRect(primary, Paint()..color = _primary.pressed || _handled ? const Color(0xFF4FCF27) : const Color(0xFF78EA3F));
      canvas.drawRRect(primary, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFFFFFFF));
      _drawText(canvas, '다음 스테이지', primaryRect, 23, const Color(0xFF13240B), FontWeight.w900, yOffset: -1);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, size.y * .64, size.x, size.y * .36), Paint()..color = const Color(0xF214082C));
      _drawText(canvas, '문 뒤에서 몬스터가 나타났습니다.', Rect.fromLTWH(size.x * .10, size.y * .682, size.x * .80, size.y * .032), 17,
          const Color(0xFFFFFFFF), FontWeight.w900);
      _drawText(canvas, '실패 시 기본적으로 두 단계 전으로 돌아갑니다.', Rect.fromLTWH(size.x * .12, size.y * .724, size.x * .76, size.y * .034), 14,
          const Color(0xFFD8C4FF), FontWeight.w800);
      final retryRect = Rect.fromLTWH(size.x * .11, size.y * .835, size.x * .78, size.y * .10);
      final retry = RRect.fromRectAndRadius(retryRect, const Radius.circular(32));
      canvas.drawRRect(retry, Paint()..color = _primary.pressed || _handled ? const Color(0xFF4FCF27) : const Color(0xFF78EA3F));
      canvas.drawRRect(retry, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFFFFFFF));
      _drawText(canvas, _handled ? '다시 시작 중...' : '다시 도전', retryRect, 24, const Color(0xFF13240B), FontWeight.w900);
    }

    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
