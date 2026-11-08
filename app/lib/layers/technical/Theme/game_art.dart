import 'dart:math';

import 'package:flutter/material.dart';

Color toolColor(String id) => switch (id) {
  'dice' => const Color(0xff8A65D8),
  'dice-tray' => const Color(0xff8A65D8),
  'picker' => const Color(0xffED8D70),
  'scores' => const Color(0xff59BBAA),
  'timer' || 'hourglass' => const Color(0xffE0AE42),
  'stopwatch' => const Color(0xff4FB3C7),
  'teams' => const Color(0xff668FCB),
  'wheel' => const Color(0xffCB78A8),
  'roles' => const Color(0xff8A65D8),
  'character' => const Color(0xffE79855),
  _ => const Color(0xff59BBAA),
};
Color toolSurface(BuildContext context, String id) => Color.lerp(
  Theme.of(context).colorScheme.surface,
  toolColor(id),
  Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.12,
)!;

class GameArt extends StatelessWidget {
  const GameArt({super.key, this.tool = 'table', this.height = 200});
  final String tool;
  final double height;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _GameArtPainter(tool)),
    ),
  );
}

class _GameArtPainter extends CustomPainter {
  const _GameArtPainter(this.tool);
  final String tool;
  static const ink = Color(0xff39304D),
      purple = Color(0xff9572DC),
      coral = Color(0xffF19B83),
      mint = Color(0xff78C8B5),
      yellow = Color(0xffF2CB69),
      cream = Color(0xffFFF9EA);
  Paint fill(Color c) => Paint()..color = c;
  void disk(Canvas c, Offset p, double r, Color color) =>
      c.drawCircle(p, r, fill(color));
  void tile(Canvas c, Rect r, Color color, {double radius = 16}) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        r.shift(const Offset(0, 5)),
        Radius.circular(radius),
      ),
      fill(ink.withValues(alpha: .10)),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(radius)),
      fill(color),
    );
  }

  void die(
    Canvas c,
    double x,
    double y,
    double side,
    double angle,
    Color color,
  ) {
    c.save();
    c.translate(x, y);
    c.rotate(angle);
    tile(
      c,
      Rect.fromCenter(center: Offset.zero, width: side, height: side),
      color,
      radius: side * .23,
    );
    for (final p in [
      Offset(-side * .22, -side * .22),
      Offset(side * .22, -side * .22),
      Offset.zero,
      Offset(-side * .22, side * .22),
      Offset(side * .22, side * .22),
    ]) {
      disk(c, p, side * .065, ink);
    }
    c.restore();
  }

  void card(
    Canvas c,
    double x,
    double y,
    double angle,
    Color color, {
    bool face = false,
  }) {
    c.save();
    c.translate(x, y);
    c.rotate(angle);
    tile(c, const Rect.fromLTWH(-39, -55, 78, 110), cream, radius: 12);
    tile(c, const Rect.fromLTWH(-31, -47, 62, 94), color, radius: 8);
    if (face) {
      disk(c, const Offset(0, -12), 14, cream);
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-23, 9, 46, 28),
          const Radius.circular(14),
        ),
        fill(cream),
      );
    } else {
      final path = Path()
        ..moveTo(0, -25)
        ..lineTo(18, 0)
        ..lineTo(0, 25)
        ..lineTo(-18, 0)
        ..close();
      c.drawPath(path, fill(cream));
    }
    c.restore();
  }

  void pawn(Canvas c, double x, double y, Color color) {
    c.save();
    c.translate(x, y);
    c.drawOval(
      const Rect.fromLTWH(-30, 35, 60, 15),
      fill(ink.withValues(alpha: .12)),
    );
    final body = Path()
      ..moveTo(-13, -15)
      ..cubicTo(-10, 8, -28, 21, -25, 34)
      ..quadraticBezierTo(0, 47, 25, 34)
      ..cubicTo(28, 21, 10, 8, 13, -15)
      ..close();
    c.drawPath(body, fill(color));
    disk(c, const Offset(0, -25), 21, color);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-28, 31, 56, 14),
        const Radius.circular(7),
      ),
      fill(color),
    );
    c.restore();
  }

  void token(Canvas c, double x, double y, Color color) {
    c.drawOval(
      Rect.fromCenter(center: Offset(x, y + 6), width: 55, height: 30),
      fill(ink.withValues(alpha: .12)),
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 55, height: 30),
      fill(color),
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(x, y - 5), width: 55, height: 30),
      fill(Color.lerp(color, cream, .22)!),
    );
    disk(c, Offset(x, y - 5), 4, cream);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(size.width / 320, size.height / 220);
    canvas.save();
    canvas.translate(
      (size.width - 320 * scale) / 2,
      (size.height - 220 * scale) / 2,
    );
    canvas.scale(scale);
    final bg = tool == 'table'
        ? const Color(0xffE7DCF8)
        : Color.lerp(toolColor(tool), cream, .67)!;
    canvas.drawOval(const Rect.fromLTWH(20, 30, 280, 166), fill(bg));
    if (tool == 'table') {
      card(canvas, 214, 94, .25, mint);
      card(canvas, 179, 92, -.1, purple);
      die(canvas, 96, 126, 100, -.2, cream);
      pawn(canvas, 251, 154, coral);
      token(canvas, 163, 189, yellow);
    } else if (tool == 'dice' || tool == 'dice-tray') {
      die(canvas, 115, 115, 103, -.23, cream);
      die(canvas, 211, 123, 86, .26, purple);
    } else if (tool == 'picker' || tool == 'teams') {
      pawn(canvas, 101, 118, coral);
      pawn(canvas, 165, 99, purple);
      pawn(canvas, 228, 132, mint);
      disk(canvas, const Offset(163, 36), 6, yellow);
    } else if (tool == 'timer' || tool == 'hourglass' || tool == 'stopwatch') {
      _timer(canvas);
    } else if (tool == 'wheel') {
      _wheel(canvas);
    } else if (tool == 'coin') {
      token(canvas, 132, 145, yellow);
      token(canvas, 192, 111, coral);
      disk(canvas, const Offset(132, 140), 12, cream);
      disk(canvas, const Offset(192, 106), 12, cream);
    } else if (tool == 'order' || tool == 'number') {
      _numbers(canvas);
    } else if (tool == 'bag') {
      _bag(canvas);
    } else if (tool == 'roles' || tool == 'character') {
      card(canvas, 127, 118, -.2, purple, face: true);
      card(canvas, 197, 112, .2, coral, face: true);
      token(canvas, 227, 180, yellow);
    } else if (tool == 'scores') {
      _scores(canvas);
    } else {
      card(canvas, 123, 109, -.2, mint);
      die(canvas, 203, 132, 84, .18, cream);
      token(canvas, 110, 184, yellow);
    }
    _sparkles(canvas);
    canvas.restore();
  }

  void _timer(Canvas canvas) {
    disk(canvas, const Offset(160, 115), 72, cream);
    disk(canvas, const Offset(160, 115), 61, yellow);
    final pen = Paint()
      ..color = ink
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(160, 115), const Offset(160, 76), pen);
    canvas.drawLine(const Offset(160, 115), const Offset(192, 132), pen);
    tile(canvas, const Rect.fromLTWH(145, 26, 30, 15), purple, radius: 7);
    disk(canvas, const Offset(160, 115), 6, ink);
  }

  void _wheel(Canvas canvas) {
    final colors = [purple, coral, mint, yellow, purple, mint];
    for (var i = 0; i < 6; i++) {
      canvas.drawArc(
        const Rect.fromLTWH(85, 40, 150, 150),
        -pi / 2 + i * pi / 3,
        pi / 3,
        true,
        fill(colors[i]),
      );
    }
    disk(canvas, const Offset(160, 115), 18, cream);
    final pointer = Path()
      ..moveTo(149, 27)
      ..lineTo(171, 27)
      ..lineTo(160, 49)
      ..close();
    canvas.drawPath(pointer, fill(ink));
  }

  void _numbers(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      tile(
        canvas,
        Rect.fromLTWH(61 + i * 69.0, 87 + (i == 1 ? -17 : 0), 59, 78),
        [purple, mint, coral][i],
      );
      final t = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontFamily: 'BricolageGrotesque',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: cream,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      t.paint(canvas, Offset(80 + i * 69.0, 99 + (i == 1 ? -17 : 0)));
    }
  }

  void _bag(Canvas canvas) {
    final bag = Path()
      ..moveTo(125, 61)
      ..quadraticBezierTo(160, 80, 195, 61)
      ..quadraticBezierTo(188, 85, 200, 103)
      ..cubicTo(242, 158, 220, 188, 160, 188)
      ..cubicTo(100, 188, 78, 158, 120, 103)
      ..quadraticBezierTo(132, 85, 125, 61)
      ..close();
    canvas.drawPath(bag, fill(mint));
    canvas.drawLine(
      const Offset(125, 82),
      const Offset(195, 82),
      Paint()
        ..color = ink
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    token(canvas, 217, 178, yellow);
    token(canvas, 99, 183, coral);
  }

  void _scores(Canvas canvas) {
    tile(canvas, const Rect.fromLTWH(75, 47, 170, 136), cream);
    for (var row = 0; row < 3; row++) {
      disk(canvas, Offset(101, 79 + row * 35), 8, [purple, coral, mint][row]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(123, 73 + row * 35, 91 - row * 13.0, 12),
          const Radius.circular(6),
        ),
        fill([purple, coral, mint][row]),
      );
    }
    token(canvas, 237, 177, yellow);
  }

  void _sparkles(Canvas canvas) {
    for (final p in [
      const Offset(32, 52),
      const Offset(288, 77),
      const Offset(276, 198),
    ]) {
      canvas.drawLine(
        p - const Offset(4, 0),
        p + const Offset(4, 0),
        Paint()
          ..color = purple
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        p - const Offset(0, 4),
        p + const Offset(0, 4),
        Paint()
          ..color = purple
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_GameArtPainter old) => old.tool != tool;
}

class DieResult extends StatelessWidget {
  const DieResult({super.key, required this.value, this.locked = false});
  final int value;
  final bool locked;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Dé $value${locked ? ", conservé" : ""}',
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xffFFF9EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked
              ? Theme.of(context).colorScheme.primary
              : const Color(0xffDDD5E8),
          width: locked ? 3 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1439304D),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: value <= 6
          ? CustomPaint(painter: _Pips(value))
          : Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff39304D),
                ),
              ),
            ),
    ),
  );
}

class _Pips extends CustomPainter {
  const _Pips(this.value);
  final int value;
  @override
  void paint(Canvas c, Size s) {
    final points = <Offset>[
      if (value.isOdd) const Offset(.5, .5),
      if (value >= 2) ...[const Offset(.26, .26), const Offset(.74, .74)],
      if (value >= 4) ...[const Offset(.74, .26), const Offset(.26, .74)],
      if (value == 6) ...[const Offset(.26, .5), const Offset(.74, .5)],
    ];
    for (final p in points) {
      c.drawCircle(
        Offset(p.dx * s.width, p.dy * s.height),
        s.width * .063,
        Paint()..color = const Color(0xff39304D),
      );
    }
  }

  @override
  bool shouldRepaint(_Pips old) => old.value != value;
}
