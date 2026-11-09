import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/presentation/pin_marker.dart';
import 'package:amiludo/layers/functional/World/presentation/world_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<MapPin?> showPinSheet(
  BuildContext context, {
  required MapPin pin,
  required bool isNew,
  required Map<String, String> creatures,
  required Map<String, String> scenes,
  required Map<String, String> maps,
  VoidCallback? onDelete,
  ValueChanged<String>? onOpenMap,
}) => showModalBottomSheet<MapPin>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => PinSheet(
    pin: pin,
    isNew: isNew,
    creatures: creatures,
    scenes: scenes,
    maps: maps,
    onDelete: onDelete,
    onOpenMap: onOpenMap,
  ),
);

class PinSheet extends StatefulWidget {
  const PinSheet({
    super.key,
    required this.pin,
    required this.isNew,
    required this.creatures,
    required this.scenes,
    required this.maps,
    this.onDelete,
    this.onOpenMap,
  });
  final MapPin pin;
  final bool isNew;
  final Map<String, String> creatures, scenes, maps;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onOpenMap;

  @override
  State<PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<PinSheet> {
  late final title = TextEditingController(text: widget.pin.title);
  late final note = TextEditingController(text: widget.pin.note);
  late PinKind kind = widget.pin.kind;
  late String? refId = widget.pin.refId;
  late String? childId = widget.pin.childMapId;
  late bool secret = widget.pin.secret;

  @override
  void dispose() {
    title.dispose();
    note.dispose();
    super.dispose();
  }

  Map<String, String> get _refs => switch (kind) {
    PinKind.npc => widget.creatures,
    PinKind.scene => widget.scenes,
    _ => const {},
  };

  void _save() {
    final links = _refs;
    final linked = refId != null && links.containsKey(refId);
    final fallback = linked ? links[refId] : null;
    final clean = title.text.trim().isEmpty
        ? (fallback ?? '')
        : title.text.trim();
    if (clean.isEmpty) return;
    Navigator.pop(
      context,
      widget.pin.copyWith(
        kind: kind,
        title: clean,
        note: note.text.trim(),
        refId: linked ? refId : null,
        clearRef: !linked,
        childMapId: childId,
        clearChild: childId == null,
        secret: secret,
      ),
    );
  }

  Widget _picker(
    String label,
    Map<String, String> options,
    String? selected,
    ValueChanged<String?> onPick,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Space.lg),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final MapEntry(key: id, value: name) in options.entries)
              ChoiceChip(
                label: Text(name),
                selected: selected == id,
                onSelected: (on) => setState(() => onPick(on ? id : null)),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: title,
              autofocus: widget.isNew,
              decoration: InputDecoration(labelText: l.worldPinTitle),
            ),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final k in PinKind.values)
                  ChoiceChip(
                    avatar: Icon(pinIcon(k), size: 18, color: pinColors[k]),
                    label: Text(context.pinKindLabel(k)),
                    selected: kind == k,
                    onSelected: (_) => setState(() {
                      kind = k;
                      refId = null;
                    }),
                  ),
              ],
            ),
            _picker(
              kind == PinKind.npc ? l.worldPinLinkNpc : l.worldPinLinkScene,
              _refs,
              refId,
              (id) => refId = id,
            ),
            _picker(
              l.worldPinOpensMap,
              widget.maps,
              childId,
              (id) => childId = id,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.worldPinSecret),
              value: secret,
              onChanged: (v) => setState(() => secret = v),
            ),
            TextField(
              controller: note,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.worldPinNote),
            ),
            const SizedBox(height: Space.lg),
            FilledButton(onPressed: _save, child: Text(l.worldSave)),
            if (widget.pin.childMapId != null && widget.onOpenMap != null)
              TextButton.icon(
                onPressed: () {
                  widget.onOpenMap!(widget.pin.childMapId!);
                  Navigator.pop(context);
                },
                icon: const DeckIcon(Icons.arrow_outward),
                label: Text(l.worldPinOpenMap),
              ),
            if (widget.onDelete != null)
              TextButton(
                onPressed: () {
                  widget.onDelete!();
                  Navigator.pop(context);
                },
                child: Text(l.worldPinDelete),
              ),
          ],
        ),
      ),
    );
  }
}
