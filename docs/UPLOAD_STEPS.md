# GitHub 업로드 순서

## 1. 이 패키지 압축 해제
폴더 구조를 확인합니다.

## 2. 우선 GitHub 저장소에 아래를 반영
- `preview/index.html`
- `assets/mockups/png/*`
- `assets/mockups/webp/*`
- `docs/*`

## 3. 업로드 방법
### 방법 A: GitHub 웹 업로드
1. 저장소 접속
2. `Add file` → `Upload files`
3. 이 패키지 내부 폴더 내용을 끌어다 놓기
4. Commit message 예시:
   - `Add MonsterDoor V7.1.0 cute UI redesign pack`

### 방법 B: 로컬 Git 사용
```bash
git add .
git commit -m "Add MonsterDoor V7.1.0 cute UI redesign pack"
git push origin main
```

## 4. 업로드 후 확인
- `preview/index.html` 이 보이는지
- `assets/mockups/webp/` 파일 4개가 올라갔는지
- 문서 4개 이상이 올라갔는지

## 5. 다음 단계
업로드가 끝나면 Flutter 쪽 실제 적용 패치(씬/컴포넌트/오디오) 작업으로 넘어갑니다.
