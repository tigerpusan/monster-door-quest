import 'dart:async';
import 'package:flame_audio/flame_audio.dart';

abstract class AudioBackend {
  Future<void> preload(List<String> files);
  Future<void> play(String file, {double volume = 1});
  Future<void> startBgm(String file, {double volume = .25});
  Future<void> stopBgm();
}

class FlameAudioBackend implements AudioBackend {
  AudioPool? _doorPool;
  AudioPool? _wrongPool;
  AudioPool? _clearPool;

  @override
  Future<void> preload(List<String> files) async {
    await FlameAudio.audioCache.loadAll(files);
    // The door sound is the most latency-sensitive sound in the game.
    // Keep multiple pre-warmed players available so rapid taps do not queue.
    _doorPool = await FlameAudio.createPool(
      AudioManager.doorOpen,
      minPlayers: 4,
      maxPlayers: 8,
    );
    _wrongPool = await FlameAudio.createPool(
      AudioManager.wrongBoom,
      minPlayers: 2,
      maxPlayers: 3,
    );
    _clearPool = await FlameAudio.createPool(
      AudioManager.clear,
      minPlayers: 1,
      maxPlayers: 2,
    );
  }

  Future<void> playDoorPool({double volume = 1}) async {
    final pool = _doorPool;
    if (pool != null) {
      await pool.start(volume: volume);
      return;
    }
    await FlameAudio.play(AudioManager.doorOpen, volume: volume);
  }

  Future<void> playWrongPool({double volume = 1}) async {
    final pool = _wrongPool;
    if (pool != null) {
      await pool.start(volume: volume);
      return;
    }
    await FlameAudio.play(AudioManager.wrongBoom, volume: volume);
  }

  Future<void> playClearPool({double volume = 1}) async {
    final pool = _clearPool;
    if (pool != null) {
      await pool.start(volume: volume);
      return;
    }
    await FlameAudio.play(AudioManager.clear, volume: volume);
  }

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
    await backend.startBgm(bgm, volume: .16);
  }

  Future<void> stopBgm() async {
    if (!_bgmPlaying) return;
    _bgmPlaying = false;
    await backend.stopBgm();
  }

  Future<void> playDoorOpen() async {
    if (!sfxEnabled) return;
    final b = backend;
    if (b is FlameAudioBackend) {
      await b.playDoorPool(volume: .70);
    } else {
      await b.play(doorOpen, volume: .70);
    }
  }

  Future<void> playWrong() async {
    if (!sfxEnabled) return;
    final b = backend;
    if (b is FlameAudioBackend) {
      await b.playWrongPool(volume: .82);
    } else {
      await b.play(wrongBoom, volume: .82);
    }
    // Do not stack a growl immediately on top of the error hit; that stacking was
    // one of the causes of delayed audio on later stages.
  }

  Future<void> playClear({bool milestoneStage = false}) async {
    if (!sfxEnabled) return;
    final b = backend;
    if (!milestoneStage && b is FlameAudioBackend) {
      await b.playClearPool(volume: .78);
      return;
    }
    await b.play(milestoneStage ? milestone : clear, volume: .78);
  }

  // Kept for compatibility with existing tests / older callers.
  Future<void> playDoorTap() => sfxEnabled ? backend.play(doorTap, volume: .45) : Future.value();
  Future<void> playDoorUnlock() => sfxEnabled ? backend.play(doorUnlock, volume: .45) : Future.value();
  Future<void> playCorrect() => sfxEnabled ? backend.play(correct, volume: .60) : Future.value();
}
