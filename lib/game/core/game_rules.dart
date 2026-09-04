import 'dart:math';

enum DoorSide { left, right }
enum MemoryCueMode { direction, color, mixed }

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
  // Preserve the current game start to avoid touching save/reset/UI behavior.
  static const initialStage = 3;
  static const finalStage = 36;
  static const realmLength = 12;
  static const playSeconds = 10.0;
  static const doorOpenSeconds = .30;
}

int stageInRealm(int stage) {
  final s = max(1, stage);
  if (s <= 12) return s;
  return ((s - 1) % GameRules.realmLength) + 1;
}

int _doorCountForStage(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 12) return s.clamp(3, 12).toInt();

  // New realms restart visually at a readable amount, then grow to 12.
  // This prevents the memory list from overflowing while preserving the
  // existing vertical single-column layout.
  final local = stageInRealm(s);
  return (local + 2).clamp(3, 12).toInt();
}

double _memorySecondsForDoorCount(int count) {
  if (count <= 3) return 5.0;
  if (count <= 5) return 4.5;
  if (count <= 8) return 4.0;
  if (count <= 11) return 3.5;
  return 3.0;
}

StageConfig stageConfig(int stage) {
  final s = max(GameRules.initialStage, stage)
      .clamp(GameRules.initialStage, GameRules.finalStage)
      .toInt();
  final count = _doorCountForStage(s);
  return StageConfig(
    stage: s,
    doorCount: count,
    memorySeconds: _memorySecondsForDoorCount(count),
    playSeconds: GameRules.playSeconds,
    maxSameRun: s <= 4 ? 3 : 2,
  );
}

MemoryCueMode memoryCueModeForStage(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 12) return MemoryCueMode.direction;
  if (s <= 24) return MemoryCueMode.color;
  return MemoryCueMode.mixed;
}

String _directionLabel(DoorSide side) =>
    side == DoorSide.left ? '←  왼쪽' : '오른쪽  →';

String _colorLabel(DoorSide side) =>
    side == DoorSide.left ? '파랑' : '빨강';

List<String> createMemoryLabels(
  List<DoorSide> route,
  int stage,
  Random rng,
) {
  final mode = memoryCueModeForStage(stage);
  if (mode == MemoryCueMode.direction) {
    return route.map(_directionLabel).toList(growable: false);
  }
  if (mode == MemoryCueMode.color) {
    return route.map(_colorLabel).toList(growable: false);
  }

  // God realm: mix direction and color wording while keeping the underlying
  // LEFT/RIGHT answer route unchanged. For 2+ items guarantee that both cue
  // types appear so the stage always feels meaningfully mixed.
  final useColor = List<bool>.generate(route.length, (_) => rng.nextBool());
  if (useColor.length >= 2) {
    if (useColor.every((v) => v)) useColor[0] = false;
    if (useColor.every((v) => !v)) useColor[0] = true;
  }

  return List<String>.generate(
    route.length,
    (i) => useColor[i] ? _colorLabel(route[i]) : _directionLabel(route[i]),
    growable: false,
  );
}

String stageRealmLabel(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 12) return '인간의 영역';
  if (s <= 24) return '초인의 영역';
  if (s <= 36) return '신의 영역';
  return '기억력 마스터';
}

String stageRealmShortLabel(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 12) return '인간';
  if (s <= 24) return '초인';
  if (s <= 36) return '신';
  return '마스터';
}

List<int> realmMilestones() => const [12, 24, 36];

int currentRealmIndex(int stage) {
  final s = max(GameRules.initialStage, stage);
  if (s <= 12) return 0;
  if (s <= 24) return 1;
  if (s <= 36) return 2;
  return 3;
}

List<DoorSide> createRoute(int count, Random rng, {required int stage}) {
  // Every route of 2+ doors must contain both directions. This prevents
  // meaningless routes such as RIGHT-RIGHT-RIGHT.
  for (var attempt = 0; attempt < 32; attempt++) {
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
    if (count < 2 ||
        (out.contains(DoorSide.left) && out.contains(DoorSide.right))) {
      return out;
    }
  }

  return List<DoorSide>.generate(
    count,
    (i) => i.isEven ? DoorSide.left : DoorSide.right,
  );
}
