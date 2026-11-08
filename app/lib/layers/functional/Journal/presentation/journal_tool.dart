import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class JournalTool extends StatefulWidget {
  const JournalTool({
    super.key,
    this.initial = const GameLog(),
    this.onChanged,
    this.now,
  });
  final GameLog initial;
  final ValueChanged<GameLog>? onChanged;
  final DateTime Function()? now;

  @override
  State<JournalTool> createState() => _JournalToolState();
}

class _JournalToolState extends State<JournalTool> {
  final tool = toolThemeFor('journal');
  final _note = TextEditingController();
  late GameLog log = widget.initial;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _commit(GameLog next) {
    setState(() => log = next);
    widget.onChanged?.call(next);
  }

  void _add() {
    final next = log.add(_note.text, (widget.now ?? DateTime.now)());
    if (identical(next, log)) return;
    tool.signal();
    _note.clear();
    _commit(next);
  }

  Widget _entry(LogEntry entry) {
    final surface = tool.surface(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final when = DateFormat.yMMMd(locale).add_Hm().format(entry.at.toLocal());
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            ToolTextureLayer(texture: tool.texture, opacity: .08),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          when,
                          style: text.labelMedium?.copyWith(
                            color: tool.ink(surface),
                          ),
                        ),
                        const SizedBox(height: Space.xs),
                        SelectableText(entry.text, style: text.bodyLarge),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.journalDelete,
                    onPressed: () => _commit(log.remove(entry.id)),
                    icon: const DeckIcon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.journalWrite),
            ),
            const SizedBox(height: Space.md),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _add,
                icon: const DeckIcon(Icons.add),
                label: Text(l.journalAdd),
              ),
            ),
            const SizedBox(height: Space.xl),
            if (log.isEmpty) Text(l.journalEmpty),
            for (final entry in log.entries) _entry(entry),
          ],
        ),
      ),
    );
  }
}
