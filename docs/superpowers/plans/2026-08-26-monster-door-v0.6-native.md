# Monster Door Quest V0.6 Native Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 HTML/Capacitor 프로토타입을 Flutter + Flame Android 네이티브 게임으로 전환하고, 60fps 목표의 즉각적인 문 열기/정오답 타격감/10초 플레이 루프를 구현한다.

**Architecture:** 저장소 루트를 Flutter 앱으로 전환하고 기존 웹 프로토타입은 `legacy-web/`에 보존한다. 게임 로직, Flame Scene/Component, 오디오, 로컬 저장을 분리하여 문 터치부터 애니메이션 시작까지 50ms 이내를 목표로 한다.

**Tech Stack:** Flutter stable, Flame 1.x, flame_audio 2.x, shared_preferences, GitHub Actions, Android Gradle

**Spec:** `docs/superpowers/specs/2026-08-26-monster-door-v0.6-native-design.md`

## Global Constraints
- Stage 3부터 시작
- 터치 후 시각 반응 시작 목표 50ms 이내
- 60fps 목표
- 문 열림 250~350ms
- 정규 Stage 플레이 입력 제한 10초
- Stage 5 이상 동일 방향 최대 2연속
- 게임 중 네트워크 호출 금지
- SFX 선로딩
- 기존 웹 버전은 `legacy-web/`로 보존

---

### Task 1: Flutter/Flame 앱 셸 및 레거시 보존
**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/game/monster_door_game.dart`
- Move: 기존 웹 파일 → `legacy-web/`
- Create: `.github/workflows/build-android.yml`
- Test: `test/app_smoke_test.dart`

**Interfaces:**
- Produces: `MonsterDoorGame extends FlameGame`

- [ ] **Step 1:** 앱 셸 smoke test 작성
- [ ] **Step 2:** `flutter test`로 실패 확인
- [ ] **Step 3:** 최소 FlameGame/MaterialApp/GameWidget 구현
- [ ] **Step 4:** 테스트 통과 확인
- [ ] **Step 5:** Android debug APK 빌드 확인

### Task 2: 게임 규칙/상태 모델
**Files:**
- Create: `lib/game/core/game_rules.dart`
- Create: `lib/game/core/game_state.dart`
- Test: `test/game_rules_test.dart`

**Interfaces:**
- Produces: `StageConfig stageConfig(int stage)`, `List<DoorSide> createRoute(int stage, Random rng)`
- Produces: `GameSessionState`

- [ ] **Step 1:** Stage 3 시작, 기억 시간, 연속 방향 제한 테스트 작성
- [ ] **Step 2:** 실패 확인
- [ ] **Step 3:** `StageConfig`, `DoorSide`, `createRoute` 구현
- [ ] **Step 4:** 테스트 통과 확인

### Task 3: Intro/Memory Scene
**Files:**
- Create: `lib/game/scenes/intro_scene.dart`
- Create: `lib/game/scenes/memory_scene.dart`
- Create: `lib/game/components/route_progress.dart`
- Test: `test/memory_flow_test.dart`

**Interfaces:**
- Consumes: `StageConfig`, `GameSessionState`
- Produces: `MemoryScene` → `DoorScene` 전환 이벤트

- [ ] **Step 1:** Stage 3에서 3개 루트 노출 테스트
- [ ] **Step 2:** 기억 타이머 만료/기억 완료 전환 테스트
- [ ] **Step 3:** Intro/Memory Scene 구현
- [ ] **Step 4:** 테스트 통과 확인

### Task 4: 고속 Door Component 및 10초 입력 제한
**Files:**
- Create: `lib/game/components/door_component.dart`
- Create: `lib/game/scenes/door_scene.dart`
- Test: `test/door_scene_test.dart`

**Interfaces:**
- Produces: `DoorComponent.open({required bool correct})`
- Produces: `DoorScene.choose(DoorSide side)`

- [ ] **Step 1:** 터치 즉시 `isOpening=true` 전환 테스트
- [ ] **Step 2:** 문 개방 duration 250~350ms 범위 테스트
- [ ] **Step 3:** 10초 만료 fail 테스트
- [ ] **Step 4:** Door Scene/Component 구현
- [ ] **Step 5:** 테스트 통과 확인

### Task 5: 정답/오답 타격감 및 캐릭터 컴포넌트
**Files:**
- Create: `lib/game/components/hero_component.dart`
- Create: `lib/game/components/princess_component.dart`
- Create: `lib/game/components/monster_component.dart`
- Create: `lib/game/effects/hit_effects.dart`
- Test: `test/hit_feedback_test.dart`

**Interfaces:**
- Produces: `playCorrectFeedback()`, `playWrongFeedback()`

- [ ] **Step 1:** 정답 시 hero dash/flash 상태 테스트
- [ ] **Step 2:** 오답 시 monster pop/shake/red flash 상태 테스트
- [ ] **Step 3:** 컴포넌트/효과 구현
- [ ] **Step 4:** 테스트 통과 확인

### Task 6: 저지연 오디오
**Files:**
- Create: `lib/game/audio/audio_manager.dart`
- Add: `assets/audio/bgm/door_tension_loop.*`
- Add: `assets/audio/sfx/door_tap.*`
- Add: `assets/audio/sfx/door_unlock.*`
- Add: `assets/audio/sfx/door_open.*`
- Add: `assets/audio/sfx/correct.*`
- Add: `assets/audio/sfx/wrong_boom.*`
- Add: `assets/audio/sfx/monster_growl.*`
- Add: `assets/audio/sfx/clear_fanfare.*`
- Test: `test/audio_manager_test.dart`

**Interfaces:**
- Produces: `AudioManager.preload()`, `playDoorOpen()`, `playCorrect()`, `playWrong()`

- [ ] **Step 1:** preload 완료 전/후 상태 테스트
- [ ] **Step 2:** 중복 재생 안전성 테스트
- [ ] **Step 3:** flame_audio 기반 매니저 구현
- [ ] **Step 4:** 테스트 통과 확인

### Task 7: Clear/Fail + 로컬 진행 저장
**Files:**
- Create: `lib/game/scenes/result_scene.dart`
- Create: `lib/game/core/progress_store.dart`
- Test: `test/progress_store_test.dart`

**Interfaces:**
- Produces: `ProgressStore.load()`, `ProgressStore.saveStage(int stage)`

- [ ] **Step 1:** 첫 실행 Stage 3 테스트
- [ ] **Step 2:** BEST/현재 Stage 저장 테스트
- [ ] **Step 3:** Clear/Fail 흐름 구현
- [ ] **Step 4:** 테스트 통과 확인

### Task 8: Android 빌드/성능 검증
**Files:**
- Modify: `.github/workflows/build-android.yml`
- Create: `docs/performance-checklist.md`

**Interfaces:**
- Produces: GitHub Actions artifact `monster-door-v0.6.0-apk`

- [ ] **Step 1:** `flutter analyze`
- [ ] **Step 2:** `flutter test`
- [ ] **Step 3:** `flutter build apk --debug`
- [ ] **Step 4:** GitHub Actions workflow 검증
- [ ] **Step 5:** 실제 Android 기기에서 터치→문 반응, 60fps, SFX 지연 체크리스트 수행
