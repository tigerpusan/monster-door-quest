import 'dart:ui';
import 'package:flame/components.dart';

class PrincessComponent extends PositionComponent {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x * .5, size.y * .92), width: size.x * .48, height: 12),
      Paint()..color = const Color(0x44000000),
    );

    final glow = Paint()
      ..color = const Color(0x66FFD98E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(size.x * .5, size.y * .34), size.x * .23, glow);

    canvas.drawCircle(Offset(size.x * .5, size.y * .30), size.x * .17, Paint()..color = const Color(0xFFFADBBC));
    final hair = Path()
      ..moveTo(size.x * .33, size.y * .31)
      ..quadraticBezierTo(size.x * .50, size.y * .10, size.x * .67, size.y * .31)
      ..lineTo(size.x * .60, size.y * .44)
      ..quadraticBezierTo(size.x * .50, size.y * .42, size.x * .40, size.y * .44)
      ..close();
    canvas.drawPath(hair, Paint()..color = const Color(0xFFF5C45A));

    final crown = Path()
      ..moveTo(size.x * .34, size.y * .14)
      ..lineTo(size.x * .41, size.y * .03)
      ..lineTo(size.x * .50, size.y * .15)
      ..lineTo(size.x * .59, size.y * .03)
      ..lineTo(size.x * .66, size.y * .14)
      ..close();
    canvas.drawPath(crown, Paint()..color = const Color(0xFFFFD960));

    canvas.drawCircle(Offset(size.x * .45, size.y * .31), 2.2, Paint()..color = const Color(0xFF281924));
    canvas.drawCircle(Offset(size.x * .55, size.y * .31), 2.2, Paint()..color = const Color(0xFF281924));
    canvas.drawArc(Rect.fromLTWH(size.x * .45, size.y * .35, size.x * .10, 8), 0, 3.14, false, Paint()..color = const Color(0xFFD97E72)..style = PaintingStyle.stroke..strokeWidth = 2);

    final dress = Path()
      ..moveTo(size.x * .38, size.y * .44)
      ..lineTo(size.x * .62, size.y * .44)
      ..lineTo(size.x * .82, size.y * .92)
      ..lineTo(size.x * .18, size.y * .92)
      ..close();
    canvas.drawPath(dress, Paint()..color = const Color(0xFFF055A0));
    canvas.drawPath(dress, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0x55FFFFFF));
  }
}
