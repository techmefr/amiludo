import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/data/avatar_randomizer.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_color_row.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_piece_grid.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_slot_labels.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_avatar.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/appearance_item.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/immersive_page.dart';
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
  late AvatarLook look = _start();
  late String slot = widget.catalogue.slots.first;

  AvatarLook _start() {
    final c = widget.catalogue;
    if (c.rig == null || !widget.initial.isEmpty) return widget.initial;
    return c.lookFor(tints: const {}, pieces: const [], hairless: false);
  }

  int? _sharedColor(AppearanceItem item) {
    final name = widget.catalogue.tintOf(item);
    if (name == null) return null;
    for (final p in look.picks.values) {
      final other = widget.catalogue.byId(p.itemId);
      if (other != null && widget.catalogue.tintOf(other) == name) {
        return p.color;
      }
    }
    return null;
  }

  void pick(AppearanceItem? item) => setState(
    () => look = look.withPick(
      slot,
      item == null ? null : AvatarPick(item.id, _sharedColor(item)),
    ),
  );

  void tint(int color) {
    final current = widget.catalogue.byId(look.picks[slot]?.itemId ?? '');
    final name = current == null ? null : widget.catalogue.tintOf(current);
    if (name == null) return;
    var next = look;
    for (final e in look.picks.entries) {
      final item = widget.catalogue.byId(e.value.itemId);
      if (item != null && widget.catalogue.tintOf(item) == name) {
        next = next.withPick(e.key, AvatarPick(e.value.itemId, color));
      }
    }
    setState(() => look = next);
  }

  void randomize() =>
      setState(() => look = randomAvatarLook(widget.catalogue, Random()));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalogue = widget.catalogue;
    final current = look.picks[slot];
    final item = current == null ? null : catalogue.byId(current.itemId);
    final tintName = item == null ? null : catalogue.tintOf(item);
    final label = avatarSlotLabel(l10n, slot);
    return ImmersivePage(
      title: l10n.avatarCreatorTitle,
      actions: [
        IconButton(
          tooltip: l10n.avatarRandomize,
          onPressed: randomize,
          icon: const Icon(Icons.casino_outlined),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, look),
          child: Text(l10n.avatarSave),
        ),
      ],
      child: ListView(
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
          if (tintName != null) ...[
            const SizedBox(height: Space.lg),
            Text(
              l10n.avatarColor,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: Space.sm),
            AvatarColorRow(
              colors: catalogue.palettes[tintName] ?? const [],
              selected: current?.color,
              onPick: tint,
            ),
          ],
          const SizedBox(height: Space.lg),
          AvatarPieceGrid(
            items: catalogue.itemsFor(slot),
            selectedId: current?.itemId,
            onPick: pick,
            slotLabel: label,
          ),
        ],
      ),
    );
  }
}
