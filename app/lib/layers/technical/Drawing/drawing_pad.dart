import 'package:flutter/material.dart';

class DrawingStroke {
  const DrawingStroke(this.points, this.color, this.width);
  final List<Offset> points;
  final Color color;
  final double width;
}

class DrawingController extends ChangeNotifier {
  DrawingController({this.color = const Color(0xFF151515), this.width = 6});

  final List<DrawingStroke> strokes = [];
  Color color;
  double width;

  bool get isEmpty => strokes.isEmpty;

  void begin(Offset p) {
    strokes.add(DrawingStroke([p], color, width));
    notifyListeners();
  }

  void extend(Offset p) {
    if (strokes.isEmpty) return;
    strokes.last.points.add(p);
    notifyListeners();
  }

  void undo() {
    if (strokes.isEmpty) return;
    strokes.removeLast();
    notifyListeners();
  }

  void clear() {
    strokes.clear();
    notifyListeners();
  }

  void setColor(Color value) {
    color = value;
    notifyListeners();
  }

  void setWidth(double value) {
    width = value;
    notifyListeners();
  }
}

class StrokesPainter extends CustomPainter {
  StrokesPainter(this.strokes, this.logical, {this.background, super.repaint});
  final List<DrawingStroke> strokes;
  final double logical;
  final Color? background;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / logical;
    canvas.clipRect(Offset.zero & size);
    if (background != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = background!);
    }
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(
          s.points.first * scale,
          s.width * scale / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()
        ..moveTo(s.points.first.dx * scale, s.points.first.dy * scale);
      for (final p in s.points.skip(1)) {
        path.lineTo(p.dx * scale, p.dy * scale);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(StrokesPainter old) => true;
}

class DrawingPad extends StatelessWidget {
  const DrawingPad({
    super.key,
    required this.controller,
    this.size = 256,
    this.background = Colors.white,
  });
  final DrawingController controller;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: GestureDetector(
      onPanStart: (d) => controller.begin(d.localPosition),
      onPanUpdate: (d) => controller.extend(d.localPosition),
      child: ClipRect(
        child: CustomPaint(
          painter: StrokesPainter(
            controller.strokes,
            size,
            background: background,
            repaint: controller,
          ),
        ),
      ),
    ),
  );
}
