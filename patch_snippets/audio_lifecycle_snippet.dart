// audio_lifecycle_snippet.dart
// 개념 예시: 실제 프로젝트 구조에 맞게 조정

class AppAudioLifecycle {
  bool _isPlaying = false;

  Future<void> playBgm() async {
    if (_isPlaying) return;
    _isPlaying = true;
    // bgmPlayer.setReleaseMode(ReleaseMode.loop);
    // await bgmPlayer.play(AssetSource('audio/bgm_main.ogg'));
  }

  Future<void> pauseBgm() async {
    _isPlaying = false;
    // await bgmPlayer.pause();
  }

  Future<void> stopBgm() async {
    _isPlaying = false;
    // await bgmPlayer.stop();
  }
}

// WidgetsBindingObserver 를 활용해 background 진입 시 pause 처리
