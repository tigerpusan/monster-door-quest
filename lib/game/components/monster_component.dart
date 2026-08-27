import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';

class MonsterComponent extends PositionComponent {
  double pop = 0;
  bool visible = false;

  void showMonster() {
    visible = true;
    pop = .20;
  }

  void hideMonster() {
    visible = false;
    pop = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (visible && pop < 1) {
      pop = (pop + dt * 5).clamp(0, 1).toDouble();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    super.render(canvas);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final s = .45 + pop * .7 - (pop > .86 ? (pop - .86) * .48 : 0);
    canvas.scale(s, s);
    canvas.translate(-size.x / 2, -size.y / 2);

    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..color = const Color(0x88D540FF);
    canvas.drawCircle(Offset(size.x * .50, size.y * .50), size.x * .38, glow);

    final head = Path()
      ..moveTo(size.x * .20, size.y * .62)
      ..quadraticBezierTo(size.x * .10, size.y * .34, size.x * .26, size.y * .20)
      ..lineTo(size.x * .32, size.y * .08)
      ..lineTo(size.x * .42, size.y * .18)
      ..quadraticBezierTo(size.x * .50, size.y * .12, size.x * .58, size.y * .18)
      ..lineTo(size.x * .68, size.y * .08)
      ..lineTo(size.x * .74, size.y * .20)
      ..quadraticBezierTo(size.x * .90, size.y * .34, size.x * .80, size.y * .62)
      ..quadraticBezierTo(size.x * .66, size.y * .84, size.x * .50, size.y * .84)
      ..quadraticBezierTo(size.x * .34, size.y * .84, size.x * .20, size.y * .62)
      ..close();
    canvas.drawPath(head, Paint()..color = const Color(0xFF8A32D4));
    canvas.drawPath(head, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFF2E0A47));

    for (final x in [size.x * .36, size.x * .64]) {
      canvas.drawCircle(Offset(x, size.y * .43), 10, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(Offset(x, size.y * .43), 4.5, Paint()..color = const Color(0xFF151515));
      canvas.drawCircle(Offset(x - 2, size.y * .40), 1.8, Paint()..color = const Color(0xFFFFFFFF));
    }

    final mouth = Path()
      ..moveTo(size.x * .35, size.y * .60)
      ..quadraticBezierTo(size.x * .50, size.y * .72, size.x * .65, size.y * .60)
      ..quadraticBezierTo(size.x * .50, size.y * .82, size.x * .35, size.y * .60)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF301124));
    canvas.drawLine(Offset(size.x * .44, size.y * .59), Offset(size.x * .47, size.y * .68), Paint()..color = const Color(0xFFFFFFFF)..strokeWidth = 3.5);
    canvas.drawLine(Offset(size.x * .56, size.y * .59), Offset(size.x * .53, size.y * .68), Paint()..color = const Color(0xFFFFFFFF)..strokeWidth = 3.5);

    final wobble = math.sin(pop * math.pi * 7) * 2;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.x * .50, size.y * .92 + wobble), width: size.x * .58, height: 12), Paint()..color = const Color(0x55000000));
    canvas.restore();
  }
}
