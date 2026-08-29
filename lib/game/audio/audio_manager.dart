import 'package:flame_audio/flame_audio.dart';

abstract class AudioBackend {
  Future<void> preload(List<String> files);
  Future<void> play(String file, {double volume = 1});
  Future<void> startBgm(String file, {double volume = .25});
  Future<void> stopBgm();
}

class FlameAudioBackend implements AudioBackend {
  @override
  Future<void> preload(List<String> files) => FlameAudio.audioCache.loadAll(files);

  @override
  Future<void> play(String file, {double volume = 1}) async {
    await FlameAudio.play(file, volume: volume);
  }

  @override
  Future<void> startBgm(String file, {double volume = .25}) async {
    await FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play(file, volume: volume);
  }

  @override
  Future<void> stopBgm() => FlameAudio.bgm.stop();
}

class AudioManager {
  AudioManager({AudioBackend? backend}) : backend = backend ?? FlameAudioBackend();

  final AudioBackend backend;
  bool isReady = false;
  bool bgmEnabled = true;
  bool sfxEnabled = true;
  bool _bgmPlaying = false;

  static const bgm = 'bgm/magic_night_loop.ogg';
  static const doorTap = 'sfx/door_tap.wav';
  static const doorUnlock = 'sfx/door_unlock.wav';
  static const doorOpen = 'sfx/door_open.wav';
  static const correct = 'sfx/correct.wav';
  static const wrongBoom = 'sfx/wrong_boom.wav';
  static const monsterGrowl = 'sfx/monster_growl.wav';
  static const clear = 'sfx/clear_fanfare.wav';
  static const milestone = 'sfx/milestone_fanfare.wav';

  Future<void> preload() async {
    await backend.preload([
      doorTap,
      doorUnlock,
      doorOpen,
      correct,
      wrongBoom,
      monsterGrowl,
      clear,
      milestone,
      bgm,
    ]);
    isReady = true;
  }

  Future<void> startBgm() async {
    if (!bgmEnabled || !isReady || _bgmPlaying) return;
    _bgmPlaying = true;
    await backend.startBgm(bgm, volume: .18);
  }

  Future<void> stopBgm() async {
    if (!_bgmPlaying) return;
    _bgmPlaying = false;
    await backend.stopBgm();
  }

  Future<void> playDoorTap() => sfxEnabled ? backend.play(doorTap, volume: .52) : Future.value();
  Future<void> playDoorUnlock() => sfxEnabled ? backend.play(doorUnlock, volume: .48) : Future.value();
  Future<void> playDoorOpen() => sfxEnabled ? backend.play(doorOpen, volume: .64) : Future.value();
  Future<void> playCorrect() => sfxEnabled ? backend.play(correct, volume: .74) : Future.value();

  Future<void> playWrong() async {
    if (!sfxEnabled) return;
    await Future.wait([
      backend.play(wrongBoom, volume: .80),
      backend.play(monsterGrowl, volume: .56),
    ]);
  }

  Future<void> playClear({bool milestoneStage = false}) =>
      sfxEnabled ? backend.play(milestoneStage ? milestone : clear, volume: .80) : Future.value();
}
