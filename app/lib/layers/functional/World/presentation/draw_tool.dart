import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';

enum DrawTool {
  move(null, Icons.pan_tool_alt_outlined),
  land(ElementKind.land, Icons.terrain),
  water(ElementKind.water, Icons.water_drop_outlined),
  forest(ElementKind.forest, Icons.park_outlined),
  mountain(ElementKind.mountain, Icons.landscape_outlined),
  road(ElementKind.road, Icons.alt_route),
  river(ElementKind.river, Icons.waves),
  wall(ElementKind.wall, Icons.border_style),
  room(ElementKind.room, Icons.crop_square),
  door(ElementKind.door, Icons.sensor_door_outlined),
  stairs(ElementKind.stairs, Icons.stairs_outlined),
  pin(null, Icons.place_outlined),
  measure(null, Icons.straighten),
  erase(null, Icons.cleaning_services_outlined);

  const DrawTool(this.kind, this.icon);
  final ElementKind? kind;
  final IconData icon;

  bool get drawsStroke => kind != null && (kind!.isBrush || kind!.isPath);

  bool get drawsRoom => kind == ElementKind.room;

  bool get placesSymbol => kind != null && kind!.isSymbol;
}

const brushSizes = [24.0, 44.0, 80.0];
