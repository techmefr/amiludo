import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Drawing/drawing_pad.dart';

const dieImageSize = 256;

Future<Uint8List> _encode(ui.Picture picture) async {
  final image = await picture.toImage(dieImageSize, dieImageSize);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

Future<Uint8List> renderDrawingPng(
  List<DrawingStroke> strokes,
  double logical, {
  Color background = Colors.white,
}) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  StrokesPainter(strokes, logical, background: background).paint(
    canvas,
    const Size(256, 256),
  );
  return _encode(recorder.endRecording());
}

Future<Uint8List> downscaleToPng(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final source = frame.image;
  final side = source.width < source.height ? source.width : source.height;
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawImageRect(
    source,
    Rect.fromLTWH(
      (source.width - side) / 2,
      (source.height - side) / 2,
      side.toDouble(),
      side.toDouble(),
    ),
    Rect.fromLTWH(0, 0, dieImageSize.toDouble(), dieImageSize.toDouble()),
    Paint()..filterQuality = FilterQuality.medium,
  );
  source.dispose();
  codec.dispose();
  return _encode(recorder.endRecording());
}

const mapImageMaxSide = 1600;

Future<Uint8List> fitToPng(Uint8List bytes, {int maxSide = mapImageMaxSide}) async {
  final probe = await ui.instantiateImageCodec(bytes);
  final first = (await probe.getNextFrame()).image;
  final (width, height) = (first.width, first.height);
  first.dispose();
  probe.dispose();
  final wide = width >= height;
  final scaled = (wide ? width : height) > maxSide;
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: scaled && wide ? maxSide : null,
    targetHeight: scaled && !wide ? maxSide : null,
  );
  final image = (await codec.getNextFrame()).image;
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  codec.dispose();
  return data!.buffer.asUint8List();
}
