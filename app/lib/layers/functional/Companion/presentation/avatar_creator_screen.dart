import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_color_row.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_piece_grid.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_slot_labels.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_avatar.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/appearance_item.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class AvatarCreatorScreen extends StatefulWidget {
  const AvatarCreatorScreen({
    super.key,
    required this.initial,
    required this.catalogue,
  });
  final AvatarLook initial;
  final AvatarCatalogue catalogue;

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen> {
  late AvatarLook look = widget.initial;
  late String slot = widget.catalogue.slots.first;

  void pick(AppearanceItem? item) => setState(
    () => look = look.withPick(
      slot,
      item == null ? null : AvatarPick(item.id, look.picks[slot]?.color),
    ),
  );

  void tint(int color) {
    final current = look.picks[slot];
    if (current == null) return;
    setState(() => look = look.withPick(slot, AvatarPick(current.itemId, color)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalogue = widget.catalogue;
    final current = look.picks[slot];
    final item = current == null ? null : catalogue.byId(current.itemId);
    final tintName = item == null ? null : catalogue.tintOf(item);
    final label = avatarSlotLabel(l10n, slot);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.avatarCreatorTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, look),
            child: Text(l10n.avatarSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          Center(
            child: SizedBox(
              height: 240,
              child: HeroAvatar(
                look: look,
                catalogue: catalogue,
                label: l10n.avatarCreatorTitle,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final s in catalogue.slots)
                ChoiceChip(
                  label: Text(avatarSlotLabel(l10n, s)),
                  selected: s == slot,
                  onSelected: (_) => setState(() => slot = s),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          AvatarPieceGrid(
            items: catalogue.itemsFor(slot),
            selectedId: current?.itemId,
            onPick: pick,
            slotLabel: label,
          ),
          if (tintName != null) ...[
            const SizedBox(height: Space.lg),
            Text(l10n.avatarColor, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: Space.sm),
            AvatarColorRow(
              colors: catalogue.palettes[tintName] ?? const [],
              selected: current?.color,
              onPick: tint,
            ),
          ],
        ],
      ),
    );
  }
}
