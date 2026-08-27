# Monster Door Quest V0.6 Native Design

## 목표
기존 HTML/Capacitor 프로토타입을 유지 가능한 참고본으로 남기고, 실제 게임 플레이는 Flutter + Flame 기반 Android 앱으로 전환한다. 핵심은 설명보다 즉시 플레이, 빠른 문 반응, 정답/오답 타격감, 반복 도전이다.

## 제품 원칙
- 첫 화면: 승인된 포스터 + `바로 시작`
- Stage 3부터 시작
- 기억 → 10초 이내 문 선택 → 즉시 피드백 → 다음 도전
- 문 터치 후 시각 반응 시작 목표: 50ms 이내
- 60fps 목표
- 문 열림 핵심 애니메이션: 250~350ms
- 게임 플레이 중 네트워크 호출 없음
- 모든 핵심 그래픽/SFX는 로컬 번들 및 선로딩
- 완성 이미지 위에 HTML/UI를 얹는 방식 금지
- 배경/문/용사/공주/몬스터/효과 레이어를 독립 게임 오브젝트로 구성

## 기술 스택
- Flutter stable
- Flame 1.x
- flame_audio 2.x
- Android 우선, 이후 iOS 확장 가능 구조
- SharedPreferences 또는 로컬 저장소로 진행도 저장

## 저장소 구조
기존 웹 프로토타입은 `legacy-web/`로 보존하고, 저장소 루트는 Flutter 앱 기준으로 전환한다.

```text
monster-door-quest/
  lib/
    main.dart
    game/
      monster_door_game.dart
      core/game_rules.dart
      core/game_state.dart
      scenes/intro_scene.dart
      scenes/memory_scene.dart
      scenes/door_scene.dart
      scenes/result_scene.dart
      components/door_component.dart
      components/hero_component.dart
      components/princess_component.dart
      components/monster_component.dart
      components/route_progress.dart
      effects/hit_effects.dart
      audio/audio_manager.dart
  assets/
    images/
      backgrounds/
      doors/
      characters/
      effects/
      ui/
    audio/
      bgm/
      sfx/
  test/
  android/
  ios/
  pubspec.yaml
  legacy-web/
```

## 게임 루프
1. 앱 실행
2. 시작 포스터 + 바로 시작
3. Stage 3부터 기억 루트 노출
4. 기억 완료 또는 기억 타이머 종료
5. Door Scene 진입
6. 10초 입력 제한 시작
7. 좌/우 문 터치
8. 터치 즉시 door press reaction
9. 문 250~350ms 개방
10. 정답이면 빛 + 정답 SFX + 용사 전진
11. 오답이면 몬스터 pop + boom/growl + 화면 shake
12. Stage Clear/Fail
13. 다음 도전 또는 재도전

## 난이도
- Stage 3~4: 최대 3회 동일 방향 연속 허용
- Stage 5+: 최대 2회 동일 방향 연속 허용
- 기억 시간:
  - 3: 5.0초
  - 4~5: 4.5초
  - 6~8: 4.0초
  - 9~11: 3.5초
  - 12~15: 3.0초
  - 16~20: 2.5초
  - 21+: 기억 시간 제한 없음 / 기록 도전
- 플레이 입력 제한: 모든 정규 Stage에서 10초

## 타격감 설계
### 정답
- PointerDown 즉시 1~2px scale-down
- lock click SFX
- 문 개방 250~350ms
- 100ms 이내 gold/blue flash
- correct chime
- hero 12~18px dash
- route node 즉시 점등

### 오답
- PointerDown 즉시 반응
- 문 개방 시작
- 120~180ms 후 내부 암전
- monster face scale 0.65 → 1.15 → 1.0
- boom + growl
- 카메라 shake 80~120ms
- red flash 70~100ms
- fail card 전환

## 오디오
- BGM: 낮은 템포의 긴장감 있는 판타지 루프
- SFX 선로딩
  - door_tap
  - door_unlock
  - door_open
  - correct
  - wrong_boom
  - monster_growl
  - clear_fanfare
  - milestone_fanfare
- SFX는 효과음 재생 지연을 최소화하는 방식으로 메모리에 준비
- BGM/SFX ON/OFF 별도 저장

## 그래픽 원칙
- AI 생성 완성 화면을 게임 배경으로 사용하지 않는다.
- 배경은 텍스트/UI 없는 순수 배경 자산만 사용한다.
- 문짝은 투명 PNG/Sprite로 분리하여 피벗 기준 회전한다.
- 용사/공주/몬스터도 독립 Sprite로 구성한다.
- 같은 화풍, 같은 라이팅, 같은 외곽선 굵기, 같은 채도 범위를 적용한다.

## V0.6 범위
- Android 실제 앱 프로젝트
- Intro / Memory / Door / Clear / Fail
- Stage 3~20 + Stage 21 기록 모드 데이터 구조
- 10초 플레이 제한
- 문 열림 애니메이션
- 정답/오답 타격감 연출
- 오디오 매니저
- 진행도 로컬 저장
- GitHub Actions APK 빌드

## V0.6 제외
- 결제/광고
- 온라인 랭킹
- 계정 로그인
- 3문/동서남북/컬러/도형 월드 실제 구현
- iOS 배포 설정 완성
