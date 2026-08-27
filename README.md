# 몬스터door V0.6.1 — Layout / Identity Patch

## 이번 패치의 핵심 원인과 수정

### 화면이 우측 하단 1/4처럼 잘린 원인
V0.6.0의 씬들을 `world`에 추가했습니다. Flame의 world 좌표는 카메라 중심 좌표계를 거치므로,
화면 전체 크기로 만든 UI 씬의 (0,0)이 실제 화면 좌상단이 아니라 카메라 월드 원점으로 취급되어
사용자 기기에서 씬이 우측/하단으로 밀려 보였습니다.

V0.6.1에서는 모든 화면형 씬을 `camera.viewport`에 추가합니다. 게임 UI는 화면 좌표계에서
좌상단 (0,0)부터 기기 viewport 전체를 사용합니다.

### 앱 식별자 고정
- 표시 이름: `몬스터door`
- Android Application ID: `com.tigerpusan.monsterdoor`
- 버전: `0.6.1+61`
- APK 파일명: `MonsterDoor-v0.6.1-release.apk`
- Artifact: `MonsterDoor-v0.6.1-release-apk`

### 아이콘
기존 승인 포스터의 두 몬스터 문 + 용사 영역을 앱 아이콘 전용으로 재구성했습니다.
기본 Flutter 아이콘을 사용하지 않습니다.

### 화면 정책
- 세로 화면 고정
- SafeArea 내부에서 GameWidget이 전체 확장
- Intro/Memory/Door/Result 씬은 screen-space(camera viewport) 렌더링

## GitHub 반영 파일
- `lib/main.dart`
- `lib/game/monster_door_game.dart`
- `lib/game/scenes/intro_scene.dart`
- `lib/game/scenes/memory_scene.dart`
- `lib/game/scenes/door_scene.dart`
- `lib/game/scenes/result_scene.dart`
- `pubspec.yaml`
- `analysis_options.yaml`
- `assets/app_icon/**`
- `.github/workflows/build-android.yml`
