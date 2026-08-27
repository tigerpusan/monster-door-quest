import 'dart:ui';
import 'package:flame/components.dart';

class HeroComponent extends PositionComponent {
  double dash = 0;

  void triggerDash() {
    dash = 1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    dash = (dash - dt * 4).clamp(0, 1).toDouble();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.translate(0, -dash * 16);

    final shadowPaint = Paint()..color = const Color(0x55000000);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.x * .5, size.y * .94), width: size.x * .52, height: 16), shadowPaint);

    final cape = Path()
      ..moveTo(size.x * .33, size.y * .40)
      ..lineTo(size.x * .12, size.y * .80)
      ..lineTo(size.x * .42, size.y * .72)
      ..close();
    canvas.drawPath(cape, Paint()..color = const Color(0xFFC5324C));

    final body = Path()
      ..moveTo(size.x * .34, size.y * .42)
      ..lineTo(size.x * .66, size.y * .42)
      ..lineTo(size.x * .76, size.y * .86)
      ..lineTo(size.x * .24, size.y * .86)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF355DBA));

    canvas.drawRect(Rect.fromLTWH(size.x * .42, size.y * .48, size.x * .16, size.y * .24), Paint()..color = const Color(0xFFE9F2FF));
    canvas.drawRect(Rect.fromLTWH(size.x * .44, size.y * .48, size.x * .12, size.y * .22), Paint()..color = const Color(0xFFD1D9E9));
    canvas.drawCircle(Offset(size.x * .50, size.y * .38), size.x * .16, Paint()..color = const Color(0xFFF7D4AF));

    final hair = Path()
      ..moveTo(size.x * .35, size.y * .31)
      ..quadraticBezierTo(size.x * .50, size.y * .17, size.x * .65, size.y * .31)
      ..lineTo(size.x * .63, size.y * .40)
      ..quadraticBezierTo(size.x * .50, size.y * .35, size.x * .37, size.y * .40)
      ..close();
    canvas.drawPath(hair, Paint()..color = const Color(0xFF4A271A));

    canvas.drawCircle(Offset(size.x * .45, size.y * .38), 2.4, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawCircle(Offset(size.x * .55, size.y * .38), 2.4, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawArc(Rect.fromLTWH(size.x * .44, size.y * .42, size.x * .12, 10), 0, 3.14, false, Paint()..color = const Color(0xFFDE8B6E)..style = PaintingStyle.stroke..strokeWidth = 2);

    final sword = Paint()..color = const Color(0xFFE8F5FF)..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.x * .70, size.y * .52), Offset(size.x * .95, size.y * .84), sword);
    canvas.drawLine(Offset(size.x * .77, size.y * .63), Offset(size.x * .88, size.y * .54), Paint()..color = const Color(0xFFC9A33B)..strokeWidth = 5);

    canvas.restore();
  }
}
