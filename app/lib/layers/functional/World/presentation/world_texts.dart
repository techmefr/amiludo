import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/presentation/draw_tool.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

extension WorldTexts on BuildContext {
  String drawToolLabel(DrawTool tool) {
    final l = l10n;
    return switch (tool) {
      DrawTool.move => l.worldToolMove,
      DrawTool.land => l.worldToolLand,
      DrawTool.water => l.worldToolWater,
      DrawTool.forest => l.worldToolForest,
      DrawTool.mountain => l.worldToolMountain,
      DrawTool.road => l.worldToolRoad,
      DrawTool.river => l.worldToolRiver,
      DrawTool.wall => l.worldToolWall,
      DrawTool.room => l.worldToolRoom,
      DrawTool.door => l.worldToolDoor,
      DrawTool.stairs => l.worldToolStairs,
      DrawTool.erase => l.worldToolErase,
    };
  }

  String scaleLevelLabel(ScaleLevel level) {
    final l = l10n;
    return switch (level) {
      ScaleLevel.world => l.worldLevelWorld,
      ScaleLevel.region => l.worldLevelRegion,
      ScaleLevel.city => l.worldLevelCity,
      ScaleLevel.building => l.worldLevelBuilding,
      ScaleLevel.room => l.worldLevelRoom,
    };
  }
}
