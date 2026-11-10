import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/type_roles.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/player_packs.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/card_pack_labels.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Drawing/boundary_png.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetView extends StatefulWidget {
  const SheetView({
    super.key,
    required this.player,
    required this.template,
    required this.onSave,
  });

  final PlayerPacks player;
  final String template;
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  State<SheetView> createState() => _SheetViewState();
}

class _SheetViewState extends State<SheetView> {
  final boundary = GlobalKey();
  bool saved = false;

  Map<String, List<CharacterCard>> get choices => {
    for (final c in widget.player.categories)
      c: [for (final d in widget.player.keptCards(c)) d.card],
  };

  Future<void> save() async {
    final character = GameCharacter(
      id: '${widget.template}-${widget.player.name}',
      name: widget.player.name,
      packName: widget.template,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      choices: choices,
    );
    await widget.onSave?.call(character);
    if (mounted) setState(() => saved = true);
  }

  Future<void> share() async {
    final png = await boundaryPng(boundary);
    if (png != null) await FileTransfer.shareImage(png, 'character.png');
  }

  Widget field(BuildContext context, String category) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: TypeRoles.kicker(context)),
          for (final d in widget.player.keptCards(category))
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(rarityIcon(d.rarity), size: 18),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: d.card.name,
                        style: theme.textTheme.titleMedium,
                        children: [
                          if (d.card.description.isNotEmpty)
                            TextSpan(
                              text: '\n${d.card.description}',
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepaintBoundary(
          key: boundary,
          child: ColoredBox(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.cpSheetTitle(widget.player.name),
                    style: TypeRoles.sectionTitle(context),
                  ),
                  Text(widget.template, style: theme.textTheme.bodySmall),
                  const SizedBox(height: Space.lg),
                  for (final c in widget.player.categories) field(context, c),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(Targets.minimum),
          ),
          onPressed: share,
          icon: const Icon(Icons.ios_share),
          label: Text(context.l10n.cpShare),
        ),
        const SizedBox(height: Space.sm),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(Targets.minimum),
          ),
          onPressed: saved || widget.onSave == null ? null : save,
          icon: Icon(saved ? Icons.check : Icons.bookmark_add_outlined),
          label: Text(saved ? context.l10n.cpSaved : context.l10n.cpSaveSheet),
        ),
      ],
    );
  }
}
