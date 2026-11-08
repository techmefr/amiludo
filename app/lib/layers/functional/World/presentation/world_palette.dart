import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';

class WorldPalette {
  const WorldPalette({
    required this.paper,
    required this.ink,
    required this.grid,
    required this.room,
    required this.fills,
    required this.lines,
  });

  final Color paper, ink, grid, room;
  final Map<ElementKind, Color> fills, lines;

  static const light = WorldPalette(
    paper: Color(0xffEBDCB2),
    ink: Color(0xff3A2A1B),
    grid: Color(0x223A2A1B),
    room: Color(0xffF6EBCB),
    fills: {
      ElementKind.land: Color(0xffD2B57A),
      ElementKind.water: Color(0xff7DB0BF),
      ElementKind.forest: Color(0xff7E9B5A),
      ElementKind.mountain: Color(0xff9C8460),
    },
    lines: {
      ElementKind.road: Color(0xff8A5A2B),
      ElementKind.river: Color(0xff3F86A8),
      ElementKind.wall: Color(0xff3A2A1B),
    },
  );

  static const dark = WorldPalette(
    paper: Color(0xff12151C),
    ink: Color(0xffD8CBB0),
    grid: Color(0x26D8CBB0),
    room: Color(0xff232937),
    fills: {
      ElementKind.land: Color(0xff3E3527),
      ElementKind.water: Color(0xff29566F),
      ElementKind.forest: Color(0xff2E4A35),
      ElementKind.mountain: Color(0xff574B3C),
    },
    lines: {
      ElementKind.road: Color(0xffC7A56C),
      ElementKind.river: Color(0xff5BA3C9),
      ElementKind.wall: Color(0xffE8DFC8),
    },
  );

  static WorldPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
