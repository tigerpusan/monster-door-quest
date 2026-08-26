# Monster Door Quest V0.1

GitHub 개발용 기초 패치 + 플레이 가능한 시안입니다.

## 포함 내용
- 모바일 100dvh UI
- Stage 1 = 3 doors, 최대 15 doors
- 기억 화면 → 좌/우 문 선택 → 성공/실패
- route 단일 소스 판정
- 한국어 / English / 中文
- Node 게임 엔진 테스트
- GitHub Pages workflow
- Capacitor Android APK workflow 기반

## GitHub 업로드
1. 새 GitHub repository 생성
2. 이 ZIP의 **폴더 안 파일 전체**를 repository root에 업로드
3. 기본 branch를 `main`으로 사용
4. Settings → Pages → Source에서 **GitHub Actions** 선택
5. Actions의 `Deploy GitHub Pages` 실행 확인

## 로컬 테스트
```bash
npm test
python -m http.server 8080
```
브라우저에서 `http://localhost:8080`

## APK
Actions → `Build Android APK` → Run workflow.
완료 후 Artifact의 `monster-door-v0.1.0-apk`에서 debug APK를 받을 수 있도록 구성했습니다.

## 다음 개발 순서
V0.1 Core → 실제 이미지 자산 → 몬스터 종류 → 사운드/진동 → 오프닝 → 도감 → Toss/Play 출시 대응
