import 'package:flutter/material.dart';

enum TarotStyle {
  nightGold(
    base: Color(0xff14122b),
    deep: Color(0xff07061a),
    line: Color(0xffe5c97a),
    paper: Color(0xfff4ecd8),
    ink: Color(0xff1f1b16),
    glow: Color(0xffe5c97a),
  ),
  bloodRed(
    base: Color(0xff7a1620),
    deep: Color(0xff3a0710),
    line: Color(0xfff0c987),
    paper: Color(0xfff6ebd9),
    ink: Color(0xff3a0710),
    glow: Color(0xffff8a5c),
  ),
  forestGreen(
    base: Color(0xff1f4d34),
    deep: Color(0xff0b2417),
    line: Color(0xffd7c27a),
    paper: Color(0xffeff0dc),
    ink: Color(0xff0b2417),
    glow: Color(0xffa8e08a),
  ),
  ivoryInk(
    base: Color(0xffefe5cc),
    deep: Color(0xffd3c4a0),
    line: Color(0xff2b2118),
    paper: Color(0xfffbf5e6),
    ink: Color(0xff2b2118),
    glow: Color(0xffc9a227),
  );

  const TarotStyle({
    required this.base,
    required this.deep,
    required this.line,
    required this.paper,
    required this.ink,
    required this.glow,
  });

  final Color base, deep, line, paper, ink, glow;

  Color get bandColor => this == ivoryInk ? ink : base;
  Color get bandInk => this == ivoryInk ? paper : line;
}

const tarotRatio = 7 / 12;

String romanNumeral(int value) {
  const table = [
    (1000, 'M'),
    (900, 'CM'),
    (500, 'D'),
    (400, 'CD'),
    (100, 'C'),
    (90, 'XC'),
    (50, 'L'),
    (40, 'XL'),
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'),
  ];
  var rest = value;
  final out = StringBuffer();
  for (final (amount, glyph) in table) {
    while (rest >= amount) {
      out.write(glyph);
      rest -= amount;
    }
  }
  return out.toString();
}
