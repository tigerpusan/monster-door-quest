import 'dart:math';

enum DoorSide { left, right }

class StageConfig {
  const StageConfig({
    required this.stage,
    required this.doorCount,
    required this.memorySeconds,
    required this.playSeconds,
    required this.maxSameRun,
  });

  final int stage;
  final int doorCount;
  final double? memorySeconds;
  final double playSeconds;
  final int maxSameRun;
}

abstract final class GameRules {
  static const initialStage = 3;
  static const playSeconds = 10.0;
  static const doorOpenSeconds = .30;
}

StageConfig stageConfig(int stage) {
  final s = max(GameRules.initialStage, stage);
  final memory =
      s <= 3 ? 5.0 : s <= 5 ? 4.5 : s <= 8 ? 4.0 : s <= 11 ? 3.5 : s <= 15 ? 3.0 : s <= 20 ? 2.5 : null;
  return StageConfig(
    stage: s,
    doorCount: s,
    memorySeconds: memory,
    playSeconds: GameRules.playSeconds,
    maxSameRun: s <= 4 ? 3 : 2,
  );
}

String stageRealmLabel(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 5) return '인간의 영역 I';
  if (s <= 10) return '인간의 영역 II';
  if (s <= 15) return '인간의 영역 III';
  if (s <= 20) return '초인의 영역';
  if (s <= 30) return '기록의 영역';
  return '신의 영역';
}

String stageRealmShortLabel(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 5) return '인간 I';
  if (s <= 10) return '인간 II';
  if (s <= 15) return '인간 III';
  if (s <= 20) return '초인';
  if (s <= 30) return '기록';
  return '신';
}

List<int> realmMilestones() => const [5, 10, 15, 20, 30, 40];

int currentRealmIndex(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 5) return 0;
  if (s <= 10) return 1;
  if (s <= 15) return 2;
  if (s <= 20) return 3;
  if (s <= 30) return 4;
  return 5;
}

List<DoorSide> createRoute(int count, Random rng, {required int stage}) {
  final out = <DoorSide>[];
  final maxRun = stageConfig(stage).maxSameRun;
  for (var i = 0; i < count; i++) {
    var pick = rng.nextBool() ? DoorSide.left : DoorSide.right;
    if (out.length >= maxRun) {
      final recent = out.sublist(out.length - maxRun);
      if (recent.every((v) => v == pick)) {
        pick = pick == DoorSide.left ? DoorSide.right : DoorSide.left;
      }
    }
    out.add(pick);
  }
  return out;
}
