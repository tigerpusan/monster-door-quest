import 'package:flame/components.dart';
import 'package:flame/events.dart';

class TapZone extends PositionComponent with TapCallbacks {
  TapZone({required this.onTap});
  final void Function() onTap;

  @override
  void onTapUp(TapUpEvent event) => onTap();
}
