import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/presentation/world_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<WorldMap?> showNewMapSheet(BuildContext context) =>
    showModalBottomSheet<WorldMap>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const NewMapSheet(),
    );

class NewMapSheet extends StatefulWidget {
  const NewMapSheet({super.key});

  @override
  State<NewMapSheet> createState() => _NewMapSheetState();
}

class _NewMapSheetState extends State<NewMapSheet> {
  final name = TextEditingController();
  ScaleLevel level = ScaleLevel.region;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _create() {
    final clean = name.text.trim();
    if (clean.isEmpty) return;
    Navigator.pop(context, WorldMap.create(clean, level));
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
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: l.worldMapName),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: Space.lg),
            Text(l.worldLevel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final v in ScaleLevel.values)
                  ChoiceChip(
                    label: Text(
                      '${context.scaleLevelLabel(v)} · ${v.cellLabel}',
                    ),
                    selected: level == v,
                    onSelected: (_) => setState(() => level = v),
                  ),
              ],
            ),
            const SizedBox(height: Space.lg),
            FilledButton(onPressed: _create, child: Text(l.worldCreate)),
          ],
        ),
      ),
    );
  }
}
