import 'package:flutter/painting.dart';

abstract final class GamePalette {
  static const ink = Color(0xff39304D),
      purple = Color(0xff9572DC),
      coral = Color(0xffF19B83),
      mint = Color(0xff78C8B5),
      yellow = Color(0xffF2CB69),
      cream = Color(0xffFFF9EA);

  static const sectors = [purple, coral, mint, yellow];

  static Color sector(int index, int count) {
    final last = index == count - 1 && count > 1 && index % sectors.length == 0;
    return sectors[last ? 2 : index % sectors.length];
  }
}
