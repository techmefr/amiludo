import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/atlas.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_kinds.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef AtlasMapBuilder = Widget Function(
  BuildContext context,
  String mapKey,
  ValueChanged<MapBoard> onChanged,
);
typedef AtlasBoardReader = MapBoard Function(String mapKey);

class AtlasMapScreen extends StatefulWidget {
  const AtlasMapScreen({
    super.key,
    required this.campaignId,
    required this.placeId,
    required this.buildMap,
    required this.readBoard,
  });

  final String campaignId, placeId;
  final AtlasMapBuilder buildMap;
  final AtlasBoardReader readBoard;

  @override
  State<AtlasMapScreen> createState() => _AtlasMapScreenState();
}

class _AtlasMapScreenState extends State<AtlasMapScreen> {
  late String key = atlasMapKey(widget.campaignId, widget.placeId);
  late List<MapMarker> markers = widget.readBoard(key).markers;

  @override
  Widget build(BuildContext context) => CampaignScope(
    id: widget.campaignId,
    builder: (context, campaign) {
      final place = campaign.entry(widget.placeId);
      if (place == null) return const Scaffold();
      final l = context.l10n;
      return Scaffold(
        appBar: AppBar(title: Text(place.name)),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: widget.buildMap(
                context,
                key,
                (board) => setState(() => markers = board.markers),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                padding: const EdgeInsets.all(Space.lg),
                children: [
                  Text(
                    l.notebookPins,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (markers.isEmpty) Text(l.notebookNoPins),
                  for (final marker in markers)
                    _PinRow(campaign: campaign, place: place, marker: marker),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _PinRow extends StatelessWidget {
  const _PinRow({
    required this.campaign,
    required this.place,
    required this.marker,
  });
  final NotebookCampaign campaign;
  final NotebookEntry place;
  final MapMarker marker;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final targetId = campaign.pinLinks[pinKey(place.id, marker.id)];
    final target = targetId == null ? null : campaign.entry(targetId);
    final label = marker.label.isEmpty ? l.notebookPinUnnamed : marker.label;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.push_pin_outlined),
      title: Text(label),
      subtitle: Text(target?.name ?? l.notebookPinUnlinked),
      onTap: target == null
          ? null
          : () => context.push(
              target.kind == EntryKind.place
                  ? '/notebook/${campaign.id}/map/${target.id}'
                  : '/notebook/${campaign.id}/entry/${target.id}',
            ),
      trailing: PopupMenuButton<String?>(
        tooltip: l.notebookPinLink,
        icon: const Icon(Icons.link),
        onSelected: (id) => context.read<NotebookCubit>().setPinLink(
          campaign.id,
          place.id,
          marker.id,
          id == '' ? null : id,
        ),
        itemBuilder: (_) => [
          PopupMenuItem(value: '', child: Text(l.notebookPinUnlinked)),
          for (final e in campaign.entries)
            PopupMenuItem(
              value: e.id,
              child: Text('${context.kindLabel(e.kind)} · ${e.name}'),
            ),
        ],
      ),
    );
  }
}
