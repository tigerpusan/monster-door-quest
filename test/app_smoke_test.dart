import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/monster_door_game.dart';
import 'package:monster_door_quest/game/audio/audio_manager.dart';
import 'package:monster_door_quest/game/core/progress_store.dart';

class MemoryProgressStore implements ProgressStorePort {
  GameProgress value = const GameProgress(currentStage: 3, bestStage: 0);
  @override GameProgress load() => value;
  @override Future<void> saveClear(int stage) async => value = GameProgress(currentStage: stage + 1, bestStage: stage);
  @override Future<void> saveCurrentStage(int stage) async => value = GameProgress(currentStage: stage, bestStage: value.bestStage);
}
class NoopAudioBackend implements AudioBackend {
  @override Future<void> preload(List<String> files) async {}
  @override Future<void> play(String file, {double volume = 1}) async {}
  @override Future<void> startBgm(String file, {double volume = .25}) async {}
  @override Future<void> stopBgm() async {}
}

void main() {
  test('game initializes with stage 3 progress', () {
    final game = MonsterDoorGame(progressStore: MemoryProgressStore(), audioManager: AudioManager(backend: NoopAudioBackend()));
    expect(game.currentStage, 3);
  });
}
