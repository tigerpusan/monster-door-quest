# GitHub 2차 Native 패치 적용

1. 기존 `monster-door-quest` 저장소의 웹 버전은 이 패치의 `legacy-web/`에 보존되어 있습니다.
2. ZIP의 **루트 내용 전체**를 저장소 루트에 업로드합니다.
3. 커밋 메시지: `Monster Door Quest V0.6 native Flutter Flame second patch`
4. GitHub **Actions** 탭 → `Build Android APK V0.6` → `Run workflow`.
5. Analyze와 Test가 통과하면 debug APK가 빌드됩니다.
6. Run 하단 **Artifacts**에서 `monster-door-v0.6.0-apk` 다운로드.

이제 GitHub Pages는 실제 앱 테스트 기준이 아닙니다. Android APK를 기기에 설치하여 터치 반응과 사운드를 확인합니다.
