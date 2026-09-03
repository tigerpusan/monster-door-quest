import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';
import 'game_help_overlay.dart';
import 'v5_image_ui.dart';

/// Full-screen fixed-art settings layer.
///
/// The picture itself is never rebuilt with Flutter controls. Only transparent
/// hit regions are active, which prevents overlap and keeps the artwork exact.
class SettingsOverlayLayer extends PositionComponent
    with HasGameReference<MonsterDoorGame>, TapCallbacks {
  SettingsOverlayLayer({required this.v5, this.onContinue});

  final V5ImageUI v5;
  final void Function()? onContinue;
  Vector2 _viewport = Vector2.zero();
  bool _open = false;

  bool get isOpen => _open;

  void resizeTo(Vector2 viewport) {
    _viewport = viewport.clone();
    if (_open) {
      position = Vector2.zero();
      size = _viewport.clone();
    }
  }

  void open() {
    if (_viewport.x <= 0 || _viewport.y <= 0) return;
    _open = true;
    position = Vector2.zero();
    size = _viewport.clone();
  }

  void close() {
    _open = false;
    position = Vector2.zero();
    size = Vector2.zero();
  }

  bool _hit(Rect r, Vector2 p) => r.contains(Offset(p.x, p.y));

  Future<void> _resetChallenge() async {
    await game.progressStore.saveCurrentStage(GameRules.initialStage);
    game.currentStage = GameRules.initialStage;
    close();
    game.goHome();
  }

  void _toggleBgm() {
    game.audioManager.bgmEnabled = !game.audioManager.bgmEnabled;
    if (game.audioManager.bgmEnabled) {
      game.audioManager.startBgm();
    } else {
      game.audioManager.stopBgm();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_open) return;
    final p = event.localPosition;
    final w = _viewport.x;
    final h = _viewport.y;

    if (_hit(GameHelpOverlay.closeRect(w, h), p)) {
      close();
      return;
    }
    if (_hit(GameHelpOverlay.musicRect(w, h), p)) {
      _toggleBgm();
      return;
    }
    if (_hit(GameHelpOverlay.resetRect(w, h), p)) {
      _resetChallenge();
      return;
    }
    if (_hit(GameHelpOverlay.continueRect(w, h), p)) {
      close();
      onContinue?.call();
      return;
    }

    // All other taps are intentionally swallowed while settings are open.
  }

  @override
  void render(Canvas canvas) {
    if (!_open) return;
    final p = game.progressStore.load();
    GameHelpOverlay.draw(
      canvas,
      _viewport.x,
      _viewport.y,
      currentStage: game.currentStage,
      bestStage: p.bestStage,
      bgmEnabled: game.audioManager.bgmEnabled,
      v5: v5,
    );
  }
}
