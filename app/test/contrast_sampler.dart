import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class TextSample {
  const TextSample(this.text, this.foreground, this.rect, this.large);
  final String text;
  final Color foreground;
  final Rect rect;
  final bool large;
}

bool _hidden(RenderObject object) {
  for (RenderObject? node = object; node != null; node = node.parent) {
    if (node is RenderOffstage && node.offstage) return true;
    if (node is RenderOpacity && node.opacity < 1) return true;
    if (node is RenderAnimatedOpacity && node.opacity.value < 1) return true;
  }
  return false;
}

void _collect(
  InlineSpan span,
  TextStyle? inherited,
  Rect rect,
  List<TextSample> out,
) {
  if (span is! TextSpan) return;
  final style = inherited?.merge(span.style) ?? span.style;
  final text = span.text;
  final color = style?.color;
  final disabled = color != null && (color.a - .38).abs() < .02;
  final glyph = text != null && text.isNotEmpty && text.runes.first >= 0xE000;
  if (text != null &&
      text.trim().isNotEmpty &&
      color != null &&
      !disabled &&
      !glyph) {
    final size = style?.fontSize ?? 14;
    final bold = (style?.fontWeight?.value ?? 400) >= 700;
    final icon = text.runes.first >= 0xE000 && text.runes.first <= 0xF8FF;
    out.add(
      TextSample(
        text,
        color,
        rect,
        icon || size >= 24 || (size >= 18.66 && bold),
      ),
    );
  }
  for (final child in span.children ?? const <InlineSpan>[]) {
    _collect(child, style, rect, out);
  }
}

Rect chrome(Size view) => Rect.fromLTRB(0, 72, view.width, view.height - 88);

List<TextSample> visibleTexts(WidgetTester tester, Size view) {
  final out = <TextSample>[];
  for (final paragraph
      in tester.allRenderObjects.whereType<RenderParagraph>()) {
    if (!paragraph.attached || !paragraph.hasSize || _hidden(paragraph)) {
      continue;
    }
    final rect = paragraph.localToGlobal(Offset.zero) & paragraph.size;
    if (rect.isEmpty || !chrome(view).contains(rect.center)) continue;
    if (rect.top < chrome(view).top || rect.bottom > chrome(view).bottom) {
      continue;
    }
    _collect(paragraph.text, null, rect, out);
  }
  return out;
}

class Pixels {
  Pixels(this.width, this.height, this.data);
  final int width, height;
  final ByteData data;

  Color? at(double x, double y) {
    final ix = x.round(), iy = y.round();
    if (ix < 0 || iy < 0 || ix >= width || iy >= height) return null;
    final i = (iy * width + ix) * 4;
    return Color.fromARGB(
      255,
      data.getUint8(i),
      data.getUint8(i + 1),
      data.getUint8(i + 2),
    );
  }
}

Future<Pixels> capture(WidgetTester tester, GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = (await tester.runAsync(() => boundary.toImage()))!;
  final data = (await tester.runAsync(() => image.toByteData()))!;
  return Pixels(image.width, image.height, data);
}

double worstAround(Pixels pixels, TextSample sample) {
  final r = sample.rect.inflate(2);
  final points = <Offset>[
    for (final f in [.1, .3, .5, .7, .9]) ...[
      Offset(r.left + r.width * f, r.top),
      Offset(r.left + r.width * f, r.bottom),
    ],
    for (final f in [.25, .75]) ...[
      Offset(r.left, r.top + r.height * f),
      Offset(r.right, r.top + r.height * f),
    ],
  ];
  final ratios = <double>[];
  for (final point in points) {
    final bg = pixels.at(point.dx, point.dy);
    if (bg == null) continue;
    ratios.add(contrastOf(sample.foreground, bg));
  }
  if (ratios.isEmpty) return double.infinity;
  ratios.sort();
  return ratios[(ratios.length * .4).floor()];
}

List<String> contrastFailures(
  Pixels pixels,
  List<TextSample> texts,
  String where,
) {
  final seen = <String>{};
  final out = <String>[];
  for (final sample in texts) {
    final need = sample.large ? aaLarge : aaText;
    final ratio = worstAround(pixels, sample);
    if (ratio >= need) continue;
    final text = sample.text.length > 24
        ? sample.text.substring(0, 24)
        : sample.text;
    final line = '$where "$text" ${ratio.toStringAsFixed(2)} < $need';
    if (seen.add(line)) out.add(line);
  }
  return out;
}
