import 'dart:math';
import 'dart:ui';

import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';

void paintFacet(Canvas canvas, Path path, Color color, DieSkin skin) {
  final bounds = path.getBounds();
  final alpha = skin.translucent ? 0.8 : 1.0;
  final shader = Gradient.linear(
    bounds.topLeft,
    bounds.bottomRight,
    [
      lighten(color, 0.14).withValues(alpha: alpha),
      color.withValues(alpha: alpha),
      darken(color, 0.16).withValues(alpha: alpha),
    ],
    const [0, 0.5, 1],
  );
  canvas.drawPath(path, Paint()..shader = shader);
  if (skin.finish == DieFinish.wood) _grain(canvas, path, bounds, color);
  if (skin.finish == DieFinish.metal) _sheen(canvas, path, bounds);
}

void _grain(Canvas canvas, Path path, Rect bounds, Color color) {
  canvas.save();
  canvas.clipPath(path);
  final paint = Paint()
    ..color = darken(color, 0.35).withValues(alpha: 0.28)
    ..strokeWidth = max(0.6, bounds.shortestSide * 0.025);
  for (var i = 0; i < 7; i++) {
    final y = bounds.top + bounds.height * (i + 0.5) / 7;
    final wobble = sin(i * 1.7) * bounds.height * 0.03;
    canvas.drawLine(
      Offset(bounds.left, y + wobble),
      Offset(bounds.right, y - wobble),
      paint,
    );
  }
  canvas.restore();
}

void _sheen(Canvas canvas, Path path, Rect bounds) {
  canvas.save();
  canvas.clipPath(path);
  canvas.drawRect(
    bounds,
    Paint()
      ..shader = Gradient.linear(
        bounds.topLeft,
        bounds.bottomRight,
        [
          const Color(0x00FFFFFF),
          const Color(0x55FFFFFF),
          const Color(0x00FFFFFF),
        ],
        const [0.25, 0.45, 0.65],
      ),
  );
  canvas.restore();
}

void paintBevel(Canvas canvas, Path path, Color color, double width) {
  canvas.save();
  canvas.clipPath(path);
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width * 2
      ..color = darken(color, 0.45).withValues(alpha: 0.4),
  );
  canvas.translate(-width * 0.35, -width * 0.35);
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width * 0.6
      ..color = lighten(color, 0.5).withValues(alpha: 0.45),
  );
  canvas.restore();
}

void paintSpecular(Canvas canvas, Path path, DieSkin skin) {
  if (skin.finish == DieFinish.matte) return;
  final soft = skin.finish == DieFinish.soft;
  final bounds = path.getBounds();
  final reach = bounds.shortestSide * 0.55;
  final spot =
      bounds.topLeft + Offset(bounds.width * 0.3, bounds.height * 0.28);
  final peak = soft ? 0.22 : (skin.finish == DieFinish.wood ? 0.18 : 0.6);
  canvas.save();
  canvas.clipPath(path);
  canvas.drawCircle(
    spot,
    reach,
    Paint()
      ..shader = Gradient.radial(spot, reach, [
        Color.fromRGBO(255, 255, 255, peak),
        const Color(0x00FFFFFF),
      ]),
  );
  canvas.restore();
}
