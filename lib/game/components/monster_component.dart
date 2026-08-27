import 'dart:ui';
import 'package:flame/components.dart';
class MonsterComponent extends PositionComponent {
  double pop = 0; bool visible = false;
  void showMonster(){ visible=true; pop=.65; }
  void hideMonster(){ visible=false; pop=0; }
  @override void update(double dt){ super.update(dt); if(visible && pop<1){ pop=(pop+dt*4).clamp(0,1).toDouble(); } }
  @override void render(Canvas canvas){
    if(!visible) return; super.render(canvas); canvas.save(); canvas.translate(size.x/2,size.y/2); final s=.65+pop*.5-(pop>.8 ? (pop-.8)*.75:0); canvas.scale(s,s); canvas.translate(-size.x/2,-size.y/2);
    canvas.drawCircle(Offset(size.x*.5,size.y*.5),size.x*.4,Paint()..color=const Color(0xFF8A2BC2));
    for(final x in [size.x*.36,size.x*.64]){ canvas.drawCircle(Offset(x,size.y*.43),6,Paint()..color=const Color(0xFFFFFFFF)); canvas.drawCircle(Offset(x,size.y*.43),3,Paint()..color=const Color(0xFF101018)); }
    canvas.drawArc(Rect.fromLTWH(size.x*.3,size.y*.48,size.x*.4,size.y*.28),0,3.14,false,Paint()..color=const Color(0xFFFFA5C9)..style=PaintingStyle.stroke..strokeWidth=5); canvas.restore();
  }
}
