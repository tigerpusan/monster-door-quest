# Monster Door Quest V0.1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** GitHub Pages에서 실행되는 Monster Door Quest V0.1과 재사용 가능한 게임 엔진/테스트/Android Actions 기반을 만든다.

**Architecture:** 순수 JavaScript ES module로 GameEngine을 UI에서 분리한다. UI는 모바일 100dvh 단일 화면이며 GameEngine이 만든 route 하나만 표시와 판정에 함께 사용한다.

**Tech Stack:** HTML5, CSS3, JavaScript ES Modules, Node.js test runner, GitHub Pages, Capacitor Android scaffold.

**Spec:** `docs/superpowers/specs/2026-08-26-monster-door-v0.1-design.md`

## Global Constraints
- 3~15 doors.
- 한 화면에 좌/우 두 문만 표시.
- route는 표시/판정 공용 단일 소스.
- 성공/실패 후 사용자 버튼으로 진행.
- 모바일 100dvh.

---

### Task 1: GameEngine
**Files:** `src/game-engine.js`, `tests/game-engine.test.js`
- [ ] RED: stage→door count, route length, 판정 progression 테스트를 먼저 작성한다.
- [ ] RED 확인: 모듈이 없어 테스트가 실패하는지 확인한다.
- [ ] GREEN: 최소 GameEngine을 구현한다.
- [ ] GREEN 확인: 전체 테스트를 통과한다.

### Task 2: Playable Mockup
**Files:** `index.html`, `src/styles.css`, `src/app.js`
- [ ] 기억 화면, 좌/우 문, 진행도, 성공/실패 화면을 구현한다.
- [ ] 모바일 100dvh 레이아웃을 적용한다.
- [ ] route 단일 소스가 UI와 판정에 연결되도록 한다.

### Task 3: GitHub-ready
**Files:** `package.json`, `.github/workflows/pages.yml`, `.github/workflows/build-android.yml`, `capacitor.config.json`, `README.md`
- [ ] GitHub Pages 자동 배포 workflow를 작성한다.
- [ ] Android GitHub Actions의 확장 기반을 작성한다.
- [ ] 저장소 업로드/실행 절차를 README에 기록한다.

### Task 4: Verification
- [ ] `node --test`를 통과한다.
- [ ] 정적 파일 경로를 검사한다.
- [ ] ZIP을 생성한다.
