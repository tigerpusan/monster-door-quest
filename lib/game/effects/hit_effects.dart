enum FlashKind { none, correct, wrong }
class HitFeedbackController {
  FlashKind flashKind = FlashKind.none;
  bool heroDashActive = false;
  bool monsterPopActive = false;
  bool shakeActive = false;
  double elapsed = 0;
  void playCorrect(){ flashKind = FlashKind.correct; heroDashActive = true; monsterPopActive = false; shakeActive = false; elapsed = 0; }
  void playWrong(){ flashKind = FlashKind.wrong; heroDashActive = false; monsterPopActive = true; shakeActive = true; elapsed = 0; }
  void update(double dt){ elapsed += dt; if (elapsed > .16) shakeActive = false; if (elapsed > .28) flashKind = FlashKind.none; if (elapsed > .34) heroDashActive = false; }
}
