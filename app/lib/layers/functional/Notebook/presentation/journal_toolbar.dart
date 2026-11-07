import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/dice_sheet.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/generator_sheet.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/oracle_panel.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/name_dialog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef LineSink = void Function(JournalKind kind, String text);

class JournalToolbar extends StatefulWidget {
  const JournalToolbar({
    super.key,
    required this.chaos,
    required this.onChaos,
    required this.onLine,
  });

  final int chaos;
  final ValueChanged<int> onChaos;
  final LineSink onLine;

  @override
  State<JournalToolbar> createState() => _JournalToolbarState();
}

class _JournalToolbarState extends State<JournalToolbar> {
  final field = TextEditingController();

  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  void submit() {
    final text = field.text.trim();
    if (text.isEmpty) return;
    widget.onLine(JournalKind.note, text);
    field.clear();
  }

  Future<void> dice() async {
    final text = await showDiceSheet(context);
    if (text != null) widget.onLine(JournalKind.dice, text);
  }

  Future<void> generator() async {
    final text = await showGeneratorSheet(context);
    if (text != null) widget.onLine(JournalKind.generator, text);
  }

  Future<void> oracle() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => SingleChildScrollView(
      padding: const EdgeInsets.all(Space.xl),
      child: OraclePanel(
        chaos: widget.chaos,
        onChaos: widget.onChaos,
        onPush: widget.onLine,
      ),
    ),
  );

  Future<void> scene() async {
    final l = context.l10n;
    final text = await showNameDialog(
      context,
      title: l.notebookToolScene,
      label: l.notebookSceneNote,
      action: l.notebookAdd,
    );
    if (text != null && text.trim().isNotEmpty) {
      widget.onLine(JournalKind.scene, text.trim());
    }
  }

  Widget tool(IconData icon, String label, VoidCallback onTap) => IconButton(
    tooltip: label,
    constraints: const BoxConstraints(
      minWidth: Targets.minimum,
      minHeight: Targets.minimum,
    ),
    onPressed: onTap,
    icon: Icon(icon),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: field,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: l.notebookQuickEntryHint,
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                  ),
                  tool(Icons.send, l.notebookAdd, submit),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  tool(Icons.casino_outlined, l.notebookToolDice, dice),
                  tool(Icons.help_outline, l.notebookToolOracle, oracle),
                  tool(
                    Icons.auto_awesome_outlined,
                    l.notebookToolGenerator,
                    generator,
                  ),
                  tool(Icons.theaters_outlined, l.notebookToolScene, scene),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
