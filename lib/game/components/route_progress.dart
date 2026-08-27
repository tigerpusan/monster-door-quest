import 'dart:ui';
import 'package:flame/components.dart';

class RouteProgress extends PositionComponent {
  RouteProgress({required this.total});

  final int total;
  int current = 0;

  void setCurrent(int value) {
    current = value;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (total <= 0) return;

    final lineY = size.y * .55;
    final startX = 22.0;
    final endX = size.x - 32;
    final dx = (endX - startX) / total;

    final linePaint = Paint()
      ..color = const Color(0x55B08DFF)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, lineY), Offset(endX, lineY), linePaint);

    for (var i = 0; i < total; i++) {
      final x = startX + dx * (i + .5);
      final done = i < current;
      final active = i == current;
      final radius = active ? 11.0 : 8.0;
      canvas.drawCircle(
        Offset(x, lineY),
        radius,
        Paint()..color = done ? const Color(0xFFFFD870) : active ? const Color(0xFFC894FF) : const Color(0xFF4A2E69),
      );
      canvas.drawCircle(
        Offset(x, lineY),
        radius,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0x88FFFFFF),
      );
    }

    final heroX = startX + dx * current.clamp(0, total - 1) + 4;
    canvas.drawCircle(Offset(heroX, lineY), 14, Paint()..color = const Color(0xFF2A4FB1));
    canvas.drawCircle(Offset(heroX, lineY - 2), 5, Paint()..color = const Color(0xFFF7D4AF));
    canvas.drawLine(Offset(heroX, lineY + 2), Offset(heroX, lineY + 11), Paint()..color = const Color(0xFFF7D4AF)..strokeWidth = 2.6);
    canvas.drawLine(Offset(heroX + 4, lineY + 3), Offset(heroX + 10, lineY + 9), Paint()..color = const Color(0xFFEAF5FF)..strokeWidth = 2.6);

    final princessX = endX + 8;
    canvas.drawCircle(Offset(princessX, lineY - 3), 13, Paint()..color = const Color(0xFFF055A0));
    final crown = Path()
      ..moveTo(princessX - 10, lineY - 20)
      ..lineTo(princessX - 4, lineY - 31)
      ..lineTo(princessX + 0, lineY - 20)
      ..lineTo(princessX + 4, lineY - 31)
      ..lineTo(princessX + 10, lineY - 20)
      ..close();
    canvas.drawPath(crown, Paint()..color = const Color(0xFFFFD95C));
  }
}
