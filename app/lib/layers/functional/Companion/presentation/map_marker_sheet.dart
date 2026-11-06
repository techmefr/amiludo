import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_icon_picker.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_palette_row.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<void> showIconSheet(
  BuildContext context, {
  required String selected,
  required ValueChanged<String> onPick,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => Padding(
    padding: EdgeInsets.fromLTRB(
      Space.lg,
      Space.lg,
      Space.lg,
      Space.lg + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: DieIconPicker(
      selected: selected,
      onPick: (id) {
        onPick(id);
        Navigator.pop(context);
      },
    ),
  ),
);

Future<void> showMarkerSheet(
  BuildContext context, {
  required MapMarker marker,
  required ValueChanged<MapMarker> onSave,
  required VoidCallback onDelete,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) =>
      _MarkerForm(marker: marker, onSave: onSave, onDelete: onDelete),
);

class _MarkerForm extends StatefulWidget {
  const _MarkerForm({
    required this.marker,
    required this.onSave,
    required this.onDelete,
  });
  final MapMarker marker;
  final ValueChanged<MapMarker> onSave;
  final VoidCallback onDelete;

  @override
  State<_MarkerForm> createState() => _MarkerFormState();
}

class _MarkerFormState extends State<_MarkerForm> {
  late final label = TextEditingController(text: widget.marker.label);
  late int color = widget.marker.color;
  late String icon = widget.marker.icon;

  @override
  void dispose() {
    label.dispose();
    super.dispose();
  }

  void save() {
    widget.onSave(
      widget.marker.copyWith(color: color, icon: icon, label: label.text.trim()),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Space.lg,
        Space.lg,
        Space.lg,
        Space.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: label,
            decoration: InputDecoration(labelText: l.mapMarkerLabel),
            onSubmitted: (_) => save(),
          ),
          const SizedBox(height: Space.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: MapPaletteRow(
              selected: color,
              onPick: (v) => setState(() => color = v),
            ),
          ),
          const SizedBox(height: Space.md),
          DieIconPicker(
            selected: icon,
            onPick: (id) => setState(() => icon = id),
          ),
          const SizedBox(height: Space.md),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  widget.onDelete();
                  Navigator.pop(context);
                },
                icon: const DeckIcon(Icons.delete_outline),
                label: Text(l.mapMarkerDelete),
              ),
              const Spacer(),
              FilledButton(
                onPressed: save,
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
