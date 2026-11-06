import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

final iconCatalog = <String, List<List<dynamic>>>{
  'sword': HugeIcons.strokeRoundedSword01,
  'shield': HugeIcons.strokeRoundedShield01,
  'crown': HugeIcons.strokeRoundedCrown,
  'skull': HugeIcons.strokeRoundedSkull,
  'fire': HugeIcons.strokeRoundedFire,
  'leaf': HugeIcons.strokeRoundedLeaf01,
  'flash': HugeIcons.strokeRoundedFlash,
  'sun': HugeIcons.strokeRoundedSun01,
  'moon': HugeIcons.strokeRoundedMoon01,
  'star': HugeIcons.strokeRoundedStar,
  'heart': HugeIcons.strokeRoundedHeart,
  'diamond': HugeIcons.strokeRoundedDiamond,
  'coins': HugeIcons.strokeRoundedCoins01,
  'key': HugeIcons.strokeRoundedKey01,
  'bomb': HugeIcons.strokeRoundedBomb,
  'ghost': HugeIcons.strokeRoundedGhost,
  'bird': HugeIcons.strokeRoundedBird,
  'tree': HugeIcons.strokeRoundedTree01,
  'mountain': HugeIcons.strokeRoundedMountain,
  'cloud': HugeIcons.strokeRoundedCloud,
  'snowflake': HugeIcons.strokeRoundedSnowflake,
  'rocket': HugeIcons.strokeRoundedRocket01,
  'anchor': HugeIcons.strokeRoundedAnchor,
  'compass': HugeIcons.strokeRoundedCompass01,
  'flag': HugeIcons.strokeRoundedFlag01,
  'trophy': HugeIcons.strokeRoundedTrophy,
  'medal': HugeIcons.strokeRoundedMedal01,
  'gift': HugeIcons.strokeRoundedGift,
  'bulb': HugeIcons.strokeRoundedBulb,
  'bug': HugeIcons.strokeRoundedBug01,
  'pickaxe': HugeIcons.strokeRoundedPickaxe,
  'crosshair': HugeIcons.strokeRoundedCrosshair,
  'target': HugeIcons.strokeRoundedTarget01,
  'castle': HugeIcons.strokeRoundedCastle,
  'home': HugeIcons.strokeRoundedHome01,
  'hammer': HugeIcons.strokeRoundedHammer,
  'wrench': HugeIcons.strokeRoundedWrench01,
  'bell': HugeIcons.strokeRoundedBell,
  'clock': HugeIcons.strokeRoundedClock01,
  'eye': HugeIcons.strokeRoundedEye,
  'smile': HugeIcons.strokeRoundedSmile,
  'sad': HugeIcons.strokeRoundedSad01,
  'angry': HugeIcons.strokeRoundedAngry,
  'plant': HugeIcons.strokeRoundedPlant01,
  'apple': HugeIcons.strokeRoundedApple,
  'cherry': HugeIcons.strokeRoundedCherry,
  'carrot': HugeIcons.strokeRoundedCarrot,
  'coffee': HugeIcons.strokeRoundedCoffee01,
  'camera': HugeIcons.strokeRoundedCamera01,
  'brush': HugeIcons.strokeRoundedBrush,
  'pen': HugeIcons.strokeRoundedPen01,
  'puzzle': HugeIcons.strokeRoundedPuzzle,
  'dice': HugeIcons.strokeRoundedDices,
  'cards': HugeIcons.strokeRoundedCards01,
  'robot': HugeIcons.strokeRoundedRobot01,
  'sparkles': HugeIcons.strokeRoundedSparkles,
  'wind': HugeIcons.strokeRoundedWind,
  'rain': HugeIcons.strokeRoundedRain,
  'umbrella': HugeIcons.strokeRoundedUmbrella,
  'music': HugeIcons.strokeRoundedMusic01,
};

List<String> searchIcons(String query) {
  final q = query.trim().toLowerCase();
  return [
    for (final id in iconCatalog.keys)
      if (q.isEmpty || id.contains(q)) id,
  ];
}

class CatalogIcon extends StatelessWidget {
  const CatalogIcon(this.id, {super.key, this.size = 24, this.color});
  final String id;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final data = iconCatalog[id];
    if (data == null) return Icon(Icons.help_outline, size: size, color: color);
    return HugeIcon(
      icon: data,
      size: size,
      color: color ?? IconTheme.of(context).color,
      strokeWidth: 1.8,
    );
  }
}
