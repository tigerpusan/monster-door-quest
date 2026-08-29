import 'package:flame/components.dart';
import 'package:flame/events.dart';

class TapZone extends PositionComponent with TapCallbacks {
  TapZone({required this.onTap, this.triggerOnDown = false});

  final void Function() onTap;
  final bool triggerOnDown;

  bool pressed = false;
  bool _fired = false;

  @override
  void onTapDown(TapDownEvent event) {
    pressed = true;
    if (triggerOnDown && !_fired) {
      _fired = true;
      onTap();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    pressed = false;
    _fired = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!triggerOnDown && !_fired) {
      _fired = true;
      onTap();
    }
    pressed = false;
    _fired = false;
  }
}
