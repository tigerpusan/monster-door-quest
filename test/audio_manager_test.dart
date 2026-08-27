import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/audio/audio_manager.dart';

class FakeAudioBackend implements AudioBackend {
  final loaded = <String>[];
  final played = <String>[];
  @override Future<void> preload(List<String> files) async => loaded.addAll(files);
  @override Future<void> play(String file, {double volume = 1}) async => played.add(file);
  @override Future<void> startBgm(String file, {double volume = .25}) async => played.add(file);
  @override Future<void> stopBgm() async {}
}

void main() {
  test('preload marks audio manager ready', () async {
    final backend = FakeAudioBackend();
    final manager = AudioManager(backend: backend);
    expect(manager.isReady, isFalse);
    await manager.preload();
    expect(manager.isReady, isTrue);
    expect(backend.loaded, contains(AudioManager.doorOpen));
  });

  test('door open and wrong feedback can be fired repeatedly', () async {
    final backend = FakeAudioBackend();
    final manager = AudioManager(backend: backend);
    await manager.preload();
    await manager.playDoorOpen();
    await manager.playDoorOpen();
    await manager.playWrong();
    expect(backend.played.where((e) => e == AudioManager.doorOpen).length, 2);
    expect(backend.played, contains(AudioManager.wrongBoom));
  });
}
