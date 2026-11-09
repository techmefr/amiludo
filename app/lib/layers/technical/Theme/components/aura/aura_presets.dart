import 'package:amiludo/layers/technical/Theme/components/aura/aura_layer.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_manifest.dart';

abstract final class AuraPresets {
  static final Map<String, AuraPreset> _shelves = {
    for (final entry in auraShelfColors.entries)
      entry.key: AuraPreset.duo(
        entry.value.$1,
        entry.value.$2,
        grain: entry.key == 'rules' ? .06 : 0,
      ),
  };

  static AuraPreset skin(String id) => auraSkins[id] ?? auraSkins['clean']!;

  static String? shelfOf(String toolId) {
    for (final entry in auraShelfTools.entries) {
      if (entry.value.contains(toolId)) return entry.key;
    }
    return null;
  }

  static AuraPreset? shelf(String? id) => _shelves[id];

  static AuraPreset tool(String toolId, String skin) =>
      shelf(shelfOf(toolId)) ?? AuraPresets.skin(skin);

  static List<AuraPreset> all() => [...auraSkins.values, ..._shelves.values];
}
