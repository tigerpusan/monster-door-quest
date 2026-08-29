// door_fast_input_notes.dart
// 개념 메모
// 1. 입력 판정과 문 열림 애니메이션을 분리
// 2. 정답 판정 직후 다음 입력 가능 플래그를 빠르게 true 로 돌려줌
// 3. 단, 중복 터치/이중 채점만 방지

class DoorInputPolicy {
  bool isLocked = false;

  bool canTap() => !isLocked;

  void onCorrectTap() {
    // 연출은 별도 비동기로 실행
    // 채점 완료 후 즉시 다음 입력 허용
  }
}
