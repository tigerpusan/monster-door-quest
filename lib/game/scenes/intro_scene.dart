import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/settings_overlay_layer.dart';
import '../ui/v5_image_ui.dart';

class IntroScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  late V5ImageUI _v5;
  late TapZone _start;
  late TapZone _settings;
  late SettingsOverlayLayer _settingsLayer;

  @override
  Future<void> onLoad() async {
    _v5 = await V5ImageUI.load();
    _start = TapZone(onTap: _startGame, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsLayer = SettingsOverlayLayer(v5: _v5)..priority = 10000;
    addAll([_start, _settings, _settingsLayer]);
  }

  void _startGame() {
    if (_settingsLayer.isOpen) return;
    game.startCurrentStage();
  }

  void _toggleSettings() {
    if (_settingsLayer.isOpen) {
      _settingsLayer.close();
    } else {
      _settingsLayer.open();
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
    _placeZone(_start, Rect.fromLTWH(size.x * .145, size.y * .846, size.x * .71, size.y * .105), priority: 1000);
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _settingsLayer.resizeTo(size);
  }

  void _drawLiveProgress(Canvas canvas) {
    final progress = game.progressStore.load();
    final stage = game.currentStage;
    final best = progress.bestStage;
    final labels = ['인간 I', '인간 II', '인간 III', '초인 I', '초인 II', '초인 III', '신'];
    final active = currentRealmIndex(stage).clamp(0, labels.length - 1);

    // The V5 intro artwork already contains the one and only outer progress box.
    // Mask only its baked sample contents with a borderless cream layer, then
    // draw the live stage/progress values.  Do NOT draw another rounded box: it
    // creates the double-frame artifact reported on real devices.
    final cover = Rect.fromLTWH(
      size.x * .070,
      size.y * .284,
      size.x * .860,
      size.y * .118,
    );
    V5ImageUI.roundedCover(
      canvas,
      cover,
      const Color(0xFFFCF3DF),
      radius: 18,
    );
    V5ImageUI.text(
      canvas,
      '현재 진행   ${stageRealmLabel(stage)}   ·   STAGE $stage   ·   최고 ${best == 0 ? '-' : best}',
      Rect.fromLTWH(size.x * .11, size.y * .291, size.x * .78, size.y * .035),
      12.6,
      const Color(0xFF173F70),
      FontWeight.w900,
    );

    final x1 = size.x * .13;
    final x2 = size.x * .87;
    final y = size.y * .350;
    final step = (x2 - x1) / (labels.length - 1);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), Paint()..color = const Color(0xFF9B95C7)..strokeWidth = 2.3);
    for (var i = 0; i < labels.length; i++) {
      final x = x1 + step * i;
      final isActive = i == active;
      canvas.drawCircle(Offset(x, y), isActive ? 10 : 8, Paint()..color = isActive ? const Color(0xFF2C78F3) : const Color(0xFF625477));
      canvas.drawCircle(Offset(x, y), isActive ? 10 : 8, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFFFFFFF));
      V5ImageUI.text(
        canvas,
        labels[i],
        Rect.fromLTWH(x - size.x * .06, y + 8, size.x * .12, size.y * .025),
        8.4,
        isActive ? const Color(0xFF2D69B1) : const Color(0xFF625477),
        FontWeight.w900,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    _v5.drawFull(canvas, size, _v5.intro);
    _drawLiveProgress(canvas);
  }
}
