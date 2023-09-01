import 'package:flutter/cupertino.dart';

class RectWithCirclePainter extends CustomPainter {
  final Color color;
  Path linePath;

  RectWithCirclePainter(this.color) {
    linePath = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('ai_log size $size');
    Paint dashedPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    linePath.reset();
    linePath.addRect(Rect.fromLTWH(0, 0, size.width, size.height * 3 / 4));
    linePath.moveTo(0, size.height * 3 / 4);
    linePath.relativeQuadraticBezierTo(size.width / 2, size.height / 4, size.width, 0);

    canvas.drawPath(
      linePath,
      dashedPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class RectWithCircleWidget extends StatelessWidget {
  final Color color;

  const RectWithCircleWidget({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: RectWithCirclePainter(color));
  }
}
