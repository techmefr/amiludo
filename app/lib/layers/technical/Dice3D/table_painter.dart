import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';
import 'package:amiludo/layers/technical/Dice3D/table_texture.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';

const double tableRim = 10;

class TablePainter extends CustomPainter {
  const TablePainter(this.table);

  final TableTheme table;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width / 2, size.height * 0.4),
          size.longestSide * 0.75,
          [lighten(table.center, 0.08), table.center, table.edge],
          const [0, 0.5, 1],
        ),
    );
    if (table.id == 'wood') {
      paintPlanks(canvas, size, table.edge);
    } else {
      paintWeave(canvas, size, table.id == 'light');
    }
    _vignette(canvas, rect);
    _rim(canvas, size);
  }

  void _vignette(Canvas canvas, Rect rect) {
    final strength = table.id == 'light' ? 0.18 : 0.38;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          rect.longestSide * 0.7,
          [const Color(0x00000000), Color.fromRGBO(0, 0, 0, strength)],
          const [0.55, 1],
        ),
    );
  }

  void _rim(Canvas canvas, Size size) {
    final outer = Offset.zero & size;
    final inner = outer.deflate(tableRim);
    final band = Path()
      ..addRect(outer)
      ..addRRect(RRect.fromRectAndRadius(inner, const Radius.circular(4)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(band, Paint()..color = table.rim);
    final lip = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = lighten(table.rim, 0.35).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.inflate(0.75), const Radius.circular(4)),
      lip,
    );
    final shadow = Paint()
      ..shader = ui.Gradient.linear(
        inner.topLeft,
        inner.topLeft + Offset(0, min(18, size.height * 0.1)),
        [const Color(0x55000000), const Color(0x00000000)],
      );
    canvas.drawRect(
      Rect.fromLTWH(inner.left, inner.top, inner.width, 18),
      shadow,
    );
  }

  @override
  bool shouldRepaint(TablePainter old) => old.table.id != table.id;
}
