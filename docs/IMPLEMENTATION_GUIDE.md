# Flutter 반영 구현 가이드

## 목표
승인된 귀여운 시안 4장을 기준으로 실제 게임 UI/UX 품질을 끌어올리되, APK 용량 증가를 최소화합니다.

## 1. 우선 수정 대상 파일(예상)
현재 대화에서 확인된 구조 기준:
- `lib/game/scenes/intro_scene.dart`
- `lib/game/scenes/memory_scene.dart`
- `lib/game/scenes/door_scene.dart`
- `lib/game/scenes/result_scene.dart`
- `lib/game/components/door_component.dart`
- `lib/game/components/action_button.dart`
- `lib/game/monster_door_game.dart`
- `lib/main.dart`
- `pubspec.yaml`

## 2. 화면별 반영 포인트
### A. 문 선택 화면
- 문을 단순 사각형에서 "마법의 이중문" 스타일로 교체
- 좌/우 라벨을 문 상단 패널로 고정
- 배경은 숲/성문/랜턴/파티클 기반의 판타지 야간 분위기
- 용사/공주 chibi 캐릭터를 하단/상단에 배치
- 진행 점 UI는 상단 중앙 고정

### B. 기억 화면
- 리스트 카드 간격 통일
- "왼쪽 / 오른쪽" 시각 강조
- 하단 CTA 버튼은 유지하되 높이와 그림자 통일
- stage, door 개수, 기억 시간 노출 정리

### C. 몬스터 어택 화면
- 현재 단색 동그라미/단순 얼굴 제거
- 귀여운 보라색 몬스터 완성형 캐릭터로 교체
- 헤드라인 / 본문 / 버튼 위치 분리
- 몬스터 그림과 문장 겹침 금지

### D. 스테이지 클리어 화면
- 승리감 있는 공주/용사 합류 장면 사용
- 보상/다음 스테이지 진행 버튼 구성
- 파티클은 가볍게 유지

## 3. 오디오 필수 수정
문제: 앱을 닫지 않고 백그라운드로 보내도 BGM이 계속 재생됨.
해결 방향:
- 앱 lifecycle 감지: `paused`, `inactive`, `detached` 시 BGM 일시정지/정지
- scene dispose 시 사운드 중단
- 중복 재생 방지 플래그 추가

## 4. 빠른 문 입력 유지
현재 개선된 장점은 유지해야 함:
- 문 1개 열고 곧바로 다음 문 터치 가능
- 문 열림 애니메이션이 입력을 막지 않도록 분리
- 판정 로직과 연출 로직을 분리

## 5. 용량 최적화
- 시안 이미지는 실제 앱 반영 시 PNG 대신 WebP 권장
- 큰 배경은 1장만 사용하고 UI는 코드 기반 장식으로 분리
- 파티클은 벡터/코드 연출 우선
- BGM은 1개 짧은 루프 + 효과음 3~5개 이내 유지
- 가능하면 `flutter build appbundle --release` 도 병행 고려
