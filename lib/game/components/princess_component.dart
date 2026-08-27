import 'dart:ui';
import 'package:flame/components.dart';
class PrincessComponent extends PositionComponent {
  @override void render(Canvas canvas){
    super.render(canvas);
    canvas.drawCircle(Offset(size.x*.5,size.y*.3),size.x*.18,Paint()..color=const Color(0xFFFFD6B0));
    canvas.drawArc(Rect.fromCircle(center:Offset(size.x*.5,size.y*.3),radius:size.x*.22),3.1,3.15,true,Paint()..color=const Color(0xFFFFC94A));
    final dress=Path()..moveTo(size.x*.38,size.y*.44)..lineTo(size.x*.62,size.y*.44)..lineTo(size.x*.82,size.y*.9)..lineTo(size.x*.18,size.y*.9)..close(); canvas.drawPath(dress,Paint()..color=const Color(0xFFF14D91));
    final crown=Path()..moveTo(size.x*.36,size.y*.12)..lineTo(size.x*.43,size.y*.02)..lineTo(size.x*.5,size.y*.12)..lineTo(size.x*.58,size.y*.02)..lineTo(size.x*.65,size.y*.12)..close(); canvas.drawPath(crown,Paint()..color=const Color(0xFFFFD74F));
  }
}
