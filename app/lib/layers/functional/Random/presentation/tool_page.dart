import 'package:flutter/material.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Random/presentation/dice_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/teams_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/pack_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_config_menu.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_library.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
  Color? tint;
  @override
  void initState() {
    super.initState();
    selected = widget.packId;
  }

  List<GameTemplate> packsFor(Workspace ws) {
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
    return unique.values
        .where(
          (p) => widget.id == 'dice'
              ? p.dice.isNotEmpty
              : widget.id == 'character'
              ? p.creation.isNotEmpty
              : p.roles.isNotEmpty,
        )
        .toList();
  }

  Widget toolFor(Workspace ws, GameTemplate? current, List<String> names) =>
      switch (widget.id) {
        'character' =>
          current == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.randomInstallACharacterPackFrom),
                    const CharacterLibrary(),
                  ],
                )
              : CharacterTool(key: ValueKey(current.id), pack: current),
        'dice' =>
          current != null
              ? PackDiceTool(key: ValueKey(current.id), pack: current)
              : widget.embeddedTools['dice-tray']?.call(context) ??
                    const DiceTool(),
        'roles' =>
          current == null
              ? RandomTool(id: 'roles', names: names)
              : PackRolesTool(
                  key: ValueKey(current.id),
                  pack: current,
                  names: names,
                ),
        'teams' => TeamsTool(
          names: names,
          lobbyNames: context.read<RandomCubit>().lobbyNames,
          haptics: ws.appearance.haptics,
        ),
        'picker' => FingerTool(
          names: names,
          haptics: ws.appearance.haptics,
          fullscreen: true,
          onTint: (c) => setState(() => tint = c),
        ),
        final id when widget.embeddedTools.containsKey(id) =>
          widget.embeddedTools[id]!(context),
        _ => RandomTool(id: widget.id, names: names),
      };

  Widget menu(GameTemplate? current, List<GameTemplate> packs) =>
      ToolConfigMenu(
        current: current,
        packs: packs,
        onSelect: (id) => setState(() => selected = id),
      );

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<RandomCubit>().state,
        names =
            ws.current?.players.map((p) => p.name).toList() ?? ws.playerNames;
    final title =
        toolDefinitions.any((t) => t.id == widget.id) ||
            widget.embeddedTools.containsKey(widget.id)
        ? context.toolTitle(widget.id)
        : null;
    if (title == null) {
      return FullPage(
        title: context.l10n.randomToolNotFound,
        child: Text(context.l10n.randomGoBackToTheToolbox),
      );
    }
    final packs = packsFor(ws);
    final current = selected == null
        ? (packs.where((p) => p.id == ws.current?.pack?.id).firstOrNull)
        : packs.where((p) => p.id == selected).firstOrNull;
    final choose = ['dice', 'roles', 'character'].contains(widget.id);
    final child = toolFor(ws, current, names);
    if (const {
      'picker',
      'map',
      'worldmap',
      'hourglass',
      'chess-clock',
      'life',
    }.contains(widget.id)) {
      return FullPage(
        title: title,
        tool: widget.id,
        immersive: true,
        background: tint,
        scroll: false,
        child: child,
      );
    }
    return FullPage(
      title: title,
      tool: widget.id,
      immersive: true,
      maxWidth: Breakpoints.contentWidth(WindowClass.large),
      fillHeight: true,
      actions: [if (choose) menu(current, packs)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child],
      ),
    );
  }
}
