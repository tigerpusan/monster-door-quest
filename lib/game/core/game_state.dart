import 'game_rules.dart';

enum SessionPhase { memory, playing, cleared, failed }
enum ChoiceResult { correct, clear, wrong, ignored }

class GameSessionState {
  GameSessionState({required this.stage, required List<DoorSide> route}) : route = List.unmodifiable(route);
  final int stage;
  final List<DoorSide> route;
  int step = 0;
  SessionPhase phase = SessionPhase.memory;

  void beginDoorRun() { phase = SessionPhase.playing; step = 0; }
  ChoiceResult choose(DoorSide side) {
    if (phase != SessionPhase.playing) return ChoiceResult.ignored;
    if (route[step] != side) { phase = SessionPhase.failed; return ChoiceResult.wrong; }
    step += 1;
    if (step == route.length) { phase = SessionPhase.cleared; return ChoiceResult.clear; }
    return ChoiceResult.correct;
  }
}
