# Monster Door Quest V0.2.0

## 1차 앱 실행본
V0.1의 단순 기억 게임을 Monster World → Chapter Map → Stage 구조로 확장한 첫 앱형 패치입니다.

### 이번 버전에서 테스트할 것
- 최초 실행 Opening Story
- World Map
- Monster Village 10 Stage Chapter Map
- `기억 완료 · 바로 시작` 즉시 작동
- 버튼을 누르지 않으면 타이머 종료 후 자동 시작
- 좌/우 문 판정
- 실패 Retry
- Stage Clear 후 지도에서 용사 이동
- Stage 10 Boss 및 Chapter Clear
- 진행 저장
- 별도 ALL/NORMAL/HARD 난이도 선택 없음

## GitHub 적용
기존 `monster-door-quest` 저장소 루트에 이 패치의 파일을 같은 경로로 덮어씁니다.

GitHub Pages가 이미 연결되어 있다면 main에 Commit하는 즉시 새 버전이 자동 배포됩니다.

## 테스트 초기화
이전 V0.2 진행을 초기화하려면 브라우저 개발자 도구에서 localStorage의 `mdq-v0.2-progress` 항목을 삭제합니다.
