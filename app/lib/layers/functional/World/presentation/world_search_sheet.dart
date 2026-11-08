import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_pins.dart';
import 'package:amiludo/layers/functional/World/presentation/pin_marker.dart';
import 'package:amiludo/layers/functional/World/presentation/world_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<PinHit?> showWorldSearch(BuildContext context, WorldAtlas atlas) =>
    showModalBottomSheet<PinHit>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WorldSearchSheet(atlas: atlas),
    );

class WorldSearchSheet extends StatefulWidget {
  const WorldSearchSheet({super.key, required this.atlas});
  final WorldAtlas atlas;

  @override
  State<WorldSearchSheet> createState() => _WorldSearchSheetState();
}

class _WorldSearchSheetState extends State<WorldSearchSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hits = widget.atlas.searchPins(query);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.worldSearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: Space.sm),
          if (hits.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Text(l.worldSearchEmpty, textAlign: TextAlign.center),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final hit in hits)
                  ListTile(
                    leading: Icon(
                      pinIcon(hit.pin.kind),
                      color: pinColors[hit.pin.kind],
                    ),
                    title: Text(hit.pin.title),
                    subtitle: Text(
                      '${hit.map.name} · ${l.worldFloor(hit.floor.name)} · '
                      '${context.pinKindLabel(hit.pin.kind)}',
                    ),
                    onTap: () => Navigator.pop(context, hit),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
