import 'dart:ui';
import 'package:flame/components.dart';

class RouteProgress extends PositionComponent {
  RouteProgress({required this.total});
  final int total;
  int current = 0;

  void setCurrent(int value) => current = value;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (total <= 0) return;
    final startX = 14.0;
    final endX = size.x - 14;
    final y = size.y * .5;
    canvas.drawLine(
      Offset(startX, y),
      Offset(endX, y),
      Paint()..color = const Color(0x99E7C9FF)..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
    final step = total == 1 ? 0.0 : (endX - startX) / (total - 1);
    for (var i = 0; i < total; i++) {
      final x = startX + step * i;
      final done = i < current;
      final active = i == current;
      final radius = active ? 10.0 : 7.0;
      canvas.drawCircle(Offset(x, y), radius + 3, Paint()..color = const Color(0x66210C42));
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = done ? const Color(0xFFFFD867) : active ? const Color(0xFF6E88FF) : const Color(0xFF543A75),
      );
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xCCFFFFFF),
      );
    }
  }
}
