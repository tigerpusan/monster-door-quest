# Monster Door Quest V0.1 Design

## Goal
GitHub에서 바로 개발을 이어갈 수 있는 모바일 우선 몬스터 문열기 게임의 최소 실행 기준본.

## Core loop
1. 문 순서를 잠깐 보여준다.
2. 힌트를 숨긴다.
3. 사용자가 좌/우 문을 순서대로 선택한다.
4. 정답이면 다음 문, 오답이면 몬스터 실패 화면.
5. 마지막 문 성공 시 공주 구출 후 NEXT STAGE.

## Rules
- Stage 1 = 3 doors, 이후 한 스테이지마다 문 1개 증가, 최대 15 doors.
- 3~6 doors: 인간의 영역 / 7~10: 초인의 영역 / 11~15: 신의 영역.
- route 배열 하나를 기억 표시와 실제 판정에 공통 사용한다.
- 성공/실패 후 자동으로 다음 스테이지로 넘어가지 않는다.
- 모바일 100dvh, 한 화면에 좌/우 두 문만 크게 표시한다.
- 한국어/영어/중국어 UI의 확장 지점을 둔다.

## GitHub structure
- 정적 웹 시안은 GitHub Pages로 바로 확인.
- GameEngine을 UI와 분리.
- Node 내장 test runner로 핵심 게임 로직 테스트.
- Android APK는 Capacitor 기반 GitHub Actions 확장 파일을 포함하되 V0.1에서는 웹 시안 검증이 우선.
