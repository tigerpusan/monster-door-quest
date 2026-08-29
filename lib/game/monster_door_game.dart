import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'audio/audio_manager.dart';
import 'core/game_rules.dart';
import 'core/game_state.dart';
import 'core/progress_store.dart';
import 'scenes/intro_scene.dart';
import 'scenes/memory_scene.dart';
import 'scenes/door_scene.dart';
import 'scenes/result_scene.dart';

class MonsterDoorGame extends FlameGame {
  MonsterDoorGame({required this.progressStore, required this.audioManager}) : currentStage = progressStore.load().currentStage;

  final ProgressStorePort progressStore;
  final AudioManager audioManager;
  int currentStage;
  Component? _scene;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await audioManager.preload();
    unawaited(audioManager.startBgm());
    await _setScene(IntroScene());
  }

  Future<void> _setScene(Component scene) async {
    _scene?.removeFromParent();
    _scene = scene;
    await camera.viewport.add(scene);
  }

  Future<void> startCurrentStage() async {
    final cfg = stageConfig(currentStage);
    final route = createRoute(cfg.doorCount, Random(), stage: currentStage);
    final session = GameSessionState(stage: currentStage, route: route);
    await _setScene(MemoryScene(session, cfg.memorySeconds));
  }

  Future<void> showDoorScene(GameSessionState session) => _setScene(DoorScene(session));

  Future<void> showResult({required bool clear, required int stage, required double elapsedSeconds}) =>
      _setScene(ResultScene(clear: clear, stage: stage, elapsedSeconds: elapsedSeconds));

  Future<void> advanceAfterClear() async {
    await progressStore.saveClear(currentStage);
    currentStage += 1;
    await startCurrentStage();
  }

  Future<void> retryCurrentStage() => startCurrentStage();
}
