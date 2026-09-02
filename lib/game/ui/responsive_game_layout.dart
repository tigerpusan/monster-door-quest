import 'dart:math' as math;
import 'dart:ui';

/// Keeps the gameplay UI on a portrait-oriented board even on wide/foldable
/// devices. Coordinates are expressed as fractions of this board.
class ResponsiveGameLayout {
  ResponsiveGameLayout(this.width, this.height)
      : boardWidth = math.min(width, height * 0.56),
        boardLeft = (width - math.min(width, height * 0.56)) / 2;

  final double width;
  final double height;
  final double boardWidth;
  final double boardLeft;

  double x(double fraction) => boardLeft + boardWidth * fraction;
  double y(double fraction) => height * fraction;
  double w(double fraction) => boardWidth * fraction;
  double h(double fraction) => height * fraction;

  Rect rect(double left, double top, double widthFraction, double heightFraction) =>
      Rect.fromLTWH(x(left), y(top), w(widthFraction), h(heightFraction));
}
