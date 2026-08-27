# Monster Door Quest V0.6 Native

기존 HTML 데모를 **Flutter + Flame Android 게임 앱**으로 전환한 2차 패치입니다.

## Core Loop
`시작 → Stage 3 기억 → 10초 문 열기 → 즉시 정답/오답 타격감 → 다음 도전`

## Native Interaction
- PointerDown 즉시 scale 반응
- 문 개방 0.30초
- 정답: green flash + correct SFX + hero dash
- 오답: red flash + monster pop + boom/growl + screen shake
- SFX preload
- 게임 중 network call 없음

## Audio
실제 APK에서 바로 검증할 수 있도록 로컬 WAV 효과음/BGM을 포함했습니다. 최종 상용 오디오 자산으로 교체할 때 파일명과 AudioManager 인터페이스는 그대로 유지할 수 있습니다.

## Build
GitHub Actions `Build Android APK V0.6` 실행 → Artifact `monster-door-v0.6.0-apk` 다운로드.

기존 웹 프로토타입은 `legacy-web/`에 보존했습니다.
