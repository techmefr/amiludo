import 'package:flutter/material.dart';

class MapSketchPainter extends CustomPainter {
  const MapSketchPainter({
    required this.progress,
    required this.ink,
    required this.mark,
  });
  final double progress;
  final Color ink, mark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final route = Path()
      ..moveTo(w * .12, h * .78)
      ..cubicTo(w * .3, h * .2, w * .5, h * 1.0, w * .72, h * .36)
      ..quadraticBezierTo(w * .8, h * .2, w * .88, h * .3);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final metric in route.computeMetrics()) {
      var at = 0.0;
      final end = metric.length * progress;
      while (at < end) {
        final to = (at + 6).clamp(0.0, end);
        canvas.drawPath(metric.extractPath(at, to), stroke);
        at += 11;
      }
    }
    final cross = Paint()
      ..color = mark
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final x = Offset(w * .88, h * .3), r = w * .05 * progress;
    canvas
      ..drawLine(x + Offset(-r, -r), x + Offset(r, r), cross)
      ..drawLine(x + Offset(r, -r), x + Offset(-r, r), cross)
      ..drawCircle(Offset(w * .12, h * .78), w * .025, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(MapSketchPainter old) =>
      old.progress != progress || old.ink != ink || old.mark != mark;
}
