import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show Alignment, LinearGradient;
import '../core/game_rules.dart';

typedef DoorSelected = void Function(DoorSide side);

class DoorComponent extends PositionComponent with TapCallbacks {
  DoorComponent({required this.side, required this.onSelected}) : super(anchor: Anchor.topLeft);
  final DoorSide side;
  final DoorSelected onSelected;
  final double openDuration = GameRules.doorOpenSeconds;
  bool isPressed = false;
  bool isOpening = false;
  bool? correct;
  double openProgress = 0;
  bool _locked = false;

  void pressDown(){ isPressed = true; scale = Vector2.all(.985); }
  void open({required bool correct}) { this.correct = correct; isOpening = true; openProgress = 0; _locked = true; }
  void resetDoor(){ isPressed = false; isOpening = false; correct = null; openProgress = 0; _locked = false; scale = Vector2.all(1); }

  @override void onTapDown(TapDownEvent event){ if (_locked) return; pressDown(); }
  @override void onTapCancel(TapCancelEvent event){ if (!_locked){ isPressed=false; scale=Vector2.all(1); } }
  @override void onTapUp(TapUpEvent event){ if (_locked) return; isPressed=false; scale=Vector2.all(1); onSelected(side); }

  @override void update(double dt){ super.update(dt); if(isOpening){ openProgress += dt/openDuration; if(openProgress>=1){openProgress=1; isOpening=false;} } }

  @override void render(Canvas canvas){
    super.render(canvas);
    final frame = RRect.fromRectAndRadius(size.toRect(), Radius.circular(size.x*.24));
    final framePaint = Paint()..shader = const LinearGradient(colors:[Color(0xFFFFD878),Color(0xFF8C591E),Color(0xFFFFE09A)],begin:Alignment.topLeft,end:Alignment.bottomRight).createShader(size.toRect());
    canvas.drawRRect(frame, framePaint);
    const inset = 10.0;
    final innerRect = Rect.fromLTWH(inset,inset,size.x-inset*2,size.y-inset*2);
    final leafPaint = Paint()..shader = LinearGradient(colors: side==DoorSide.left ? const [Color(0xFF4876F2),Color(0xFF142B77)] : const [Color(0xFFB14ED0),Color(0xFF541270)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(innerRect);
    canvas.save();
    if(openProgress>0){
      final pivotX = side==DoorSide.left ? inset : size.x-inset;
      final sx = 1 - openProgress*.82;
      canvas.translate(pivotX,0); canvas.scale(sx,1); canvas.translate(-pivotX,0);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(size.x*.19)), leafPaint);
    final gem = Path()..moveTo(size.x*.5,size.y*.13)..lineTo(size.x*.57,size.y*.19)..lineTo(size.x*.5,size.y*.25)..lineTo(size.x*.43,size.y*.19)..close();
    canvas.drawPath(gem, Paint()..color = side==DoorSide.left ? const Color(0xFF65E5FF) : const Color(0xFFFF8CFF));
    final knobX = side==DoorSide.left ? size.x*.78 : size.x*.22;
    canvas.drawCircle(Offset(knobX,size.y*.58),8,Paint()..color=const Color(0xFFFFD36A));
    canvas.restore();
    if(correct!=null){ canvas.drawRRect(frame, Paint()..style=PaintingStyle.stroke..strokeWidth=4..color=correct! ? const Color(0xFF5CFFAA) : const Color(0xFFFF5B78)); }
  }
}
