import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/full_page.dart';
import '../../../technical/Theme/deck_widgets.dart';
import '../../Workspace/workspace_controller.dart';
import '../../Templates/domain/game_template.dart';
import '../../Timer/presentation/timer_panel.dart';
import '../../Game/presentation/game_screen.dart';
import '../domain/tool_catalog.dart';
import 'dice_tool.dart';
import 'finger_tool.dart';
import 'random_tool.dart';
import 'pack_tools.dart';
import 'character_tool.dart';
import 'character_library.dart';

class ToolPage extends ConsumerStatefulWidget {
  const ToolPage({
    super.key,
    required this.id,
    this.packId,
    this.snapshot = false,
  });
  final String id;
  final String? packId;
  final bool snapshot;
  @override
  ConsumerState<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends ConsumerState<ToolPage> {
  String? selected;
  @override
  void initState() {
    super.initState();
    selected = widget.packId;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    if (!state.hasValue) {
      return const FullPage(title: 'Outil', child: WorkspaceWait());
    }
    final ws = state.requireValue,
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
      'scores' => const GameScreen(),
      'timer' => const TimerPanel(),
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
