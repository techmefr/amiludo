import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';

class ToolSwitchMenu extends StatelessWidget {
  const ToolSwitchMenu({super.key, required this.id, required this.shelf});

  final String id;
  final ToolShelf shelf;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: context.toolShelfLabel(shelf.id),
    icon: const Icon(Icons.keyboard_arrow_down),
    initialValue: id,
    onSelected: (tool) {
      if (tool != id) context.replace('/tools/$tool');
    },
    itemBuilder: (context) => [
      for (final tool in shelf.tools)
        PopupMenuItem(
          value: tool,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(toolIcon(tool)),
            title: Text(context.toolTitle(tool)),
            selected: id == tool,
          ),
        ),
    ],
  );
}
