# DoorMission Pixel V6 – Fixed Art Layer

## 핵심 변경
- 스테이지 클리어 화면: 고정 베이스 이미지 사용, 동적 완료시간/영역/스테이지 문구 제거
- 게임 설정: 고정 베이스 이미지 사용, 현재 스테이지/최고 수치만 작은 투명 텍스트로 표시
- 문 순서 기억 화면: 고정 베이스 이미지 사용, 중앙 리스트와 기억시간만 동적 오버레이
- 모든 중첩 박스/작은 박스/불필요한 커버 레이어 제거

## 포함 베이스 에셋
- `assets/images/ui/v6/clear_template.png`
- `assets/images/ui/v6/settings_template.png`
- `assets/images/ui/v6/memory_template.png`

## 코드 변경 파일
- `lib/game/scenes/memory_scene.dart`
- `lib/game/scenes/result_scene.dart`
- `lib/game/ui/game_help_overlay.dart`
- `lib/game/ui/v5_image_ui.dart`
- `pubspec.yaml`
