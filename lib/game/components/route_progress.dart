import 'dart:ui';
import 'package:flame/components.dart';
class RouteProgress extends PositionComponent {
  RouteProgress({required this.total}); final int total; int current = 0; void setCurrent(int value){ current=value; }
  @override void render(Canvas canvas){ super.render(canvas); if(total<=0)return; final gap=size.x/(total+1); for(var i=0;i<total;i++){ final done=i<current; final active=i==current; canvas.drawCircle(Offset(gap*(i+1),size.y/2),active?8:6,Paint()..color=done?const Color(0xFFFFD46D):active?const Color(0xFFBC8CFF):const Color(0xFF3D285B)); } }
}
