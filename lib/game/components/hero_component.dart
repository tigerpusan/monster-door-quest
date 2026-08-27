import 'dart:ui';
import 'package:flame/components.dart';
class HeroComponent extends PositionComponent {
  double dash = 0;
  void triggerDash(){ dash = 1; }
  @override void update(double dt){ super.update(dt); dash = (dash - dt*4).clamp(0,1).toDouble(); }
  @override void render(Canvas canvas){
    super.render(canvas); canvas.save(); canvas.translate(0,-dash*12);
    canvas.drawCircle(Offset(size.x*.5,size.y*.28),size.x*.16,Paint()..color=const Color(0xFFFFD2A6));
    canvas.drawArc(Rect.fromCircle(center:Offset(size.x*.5,size.y*.23),radius:size.x*.19),3.15,3.1,true,Paint()..color=const Color(0xFF4B2415));
    final body=Path()..moveTo(size.x*.32,size.y*.42)..lineTo(size.x*.68,size.y*.42)..lineTo(size.x*.76,size.y*.86)..lineTo(size.x*.24,size.y*.86)..close();
    canvas.drawPath(body,Paint()..color=const Color(0xFF244A9B));
    final cape=Path()..moveTo(size.x*.28,size.y*.42)..lineTo(size.x*.08,size.y*.8)..lineTo(size.x*.4,size.y*.72)..close(); canvas.drawPath(cape,Paint()..color=const Color(0xFFB52D38));
    canvas.drawLine(Offset(size.x*.7,size.y*.52),Offset(size.x*.93,size.y*.83),Paint()..color=const Color(0xFFEAF5FF)..strokeWidth=6); canvas.restore();
  }
}
