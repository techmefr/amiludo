import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Random/presentation/dice_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/pack_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_library.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({
    super.key,
    required this.id,
    this.packId,
    this.snapshot = false,
    this.embeddedTools = const {},
  });
  final String id;
  final String? packId;
  final bool snapshot;
  final Map<String, WidgetBuilder> embeddedTools;
  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  String? selected;
  @override
  void initState() {
    super.initState();
    selected = widget.packId;
  }

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<RandomCubit>().state,
        names =
            ws.current?.players.map((p) => p.name).toList() ?? ws.playerNames;
    final title = toolDefinitions
        .where((t) => t.id == widget.id)
        .firstOrNull
        ?.title;
    if (title == null) {
      return const FullPage(
        title: 'Outil introuvable',
        child: Text('Revenez à la boîte à outils.'),
      );
    }
    final available = [
      if ((widget.snapshot || widget.packId == null) &&
          ws.current?.pack != null)
        ws.current!.pack!,
      ...ws.templates,
      ...GameTemplate.builtIn,
      if (ws.current?.pack != null) ws.current!.pack!,
    ];
    final unique = <String, GameTemplate>{};
    for (final p in available) {
      unique.putIfAbsent(p.id, () => p);
    }
    final packs = unique.values
        .where(
          (p) => widget.id == 'dice'
              ? p.dice.isNotEmpty
              : widget.id == 'character'
              ? p.creation.isNotEmpty
              : p.roles.isNotEmpty,
        )
        .toList();
    final current = selected == null
        ? (packs.where((p) => p.id == ws.current?.pack?.id).firstOrNull)
        : packs.where((p) => p.id == selected).firstOrNull;
    final choose = ['dice', 'roles', 'character'].contains(widget.id);
    final child = switch (widget.id) {
      'character' =>
        current == null
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Installez un pack de personnages dans la galerie, ou créez vos catégories dans le builder.',
                  ),
                  CharacterLibrary(),
                ],
              )
            : CharacterTool(key: ValueKey(current.id), pack: current),
      'dice' =>
        current == null
            ? const DiceTool()
            : PackDiceTool(key: ValueKey(current.id), pack: current),
      'roles' =>
        current == null
            ? RandomTool(id: 'roles', names: names)
            : PackRolesTool(
                key: ValueKey(current.id),
                pack: current,
                names: names,
              ),
      'picker' => FingerTool(
        names: names,
        haptics: ws.appearance.haptics,
        fullscreen: true,
      ),
      final id when widget.embeddedTools.containsKey(id) =>
        widget.embeddedTools[id]!(context),
      _ => RandomTool(id: widget.id, names: names),
    };
    if (widget.id == 'picker') {
      return FullPage(
        title: title,
        scroll: false,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
    }
    return FullPage(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (choose) ...[
            DropdownButtonFormField<String>(
              style: Theme.of(context).textTheme.bodyLarge,
              key: ValueKey(current?.id ?? ''),
              initialValue: current?.id ?? '',
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Configuration de jeu',
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Outil libre')),
                for (final p in packs)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (v) => setState(() => selected = v),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    current == null ? '/builder/new' : '/builder/${current.id}',
                  ),
                  icon: const DeckIcon(Icons.build_outlined),
                  label: const Text('Ouvrir le builder'),
                ),
                TextButton(
                  onPressed: () => context.push('/marketplace'),
                  child: const Text('Trouver un pack'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          child,
        ],
      ),
    );
  }
}
