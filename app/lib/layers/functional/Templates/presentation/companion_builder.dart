import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_ids.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/add_brick_picker.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_row.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CompanionBuilder extends StatefulWidget {
  const CompanionBuilder({super.key, this.id});
  final String? id;

  @override
  State<CompanionBuilder> createState() => _CompanionBuilderState();
}

class _CompanionBuilderState extends State<CompanionBuilder> {
  late final GameTemplate? existing = context
      .read<TemplatesCubit>()
      .state
      .templates
      .where((t) => t.id == widget.id)
      .firstOrNull;
  late final String id =
      existing?.id ?? 'companion-${DateTime.now().microsecondsSinceEpoch}';
  late final TextEditingController name = TextEditingController(
    text: existing?.name ?? '',
  );
  late Companion draft = Companion(
    id: id,
    name: name.text,
    bricks: existing?.bricks ?? const [],
  );

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _change(Companion next) => setState(() => draft = next);

  Future<void> _add() async {
    if (draft.bricks.length >= 64) return;
    final picked = await pickBrick(context);
    if (picked == null) return;
    _change(draft.add(draft.bricks.withFreeId(picked)));
  }

  Future<GameTemplate> _save() async {
    final base = existing ?? GameTemplate(id: id, name: name.text);
    final template = GameTemplate.fromJson({
      ...base.toJson(),
      'name': name.text.trim().isEmpty
          ? context.l10n.buildTitle
          : name.text.trim(),
      'bricks': [for (final b in draft.bricks) b.toJson()],
    });
    await context.read<TemplatesCubit>().addTemplate(template);
    return template;
  }

  Future<void> _saveAndNotify() async {
    await _save();
    if (mounted) notify(context, context.l10n.buildSaved);
  }

  Future<void> _launch() async {
    final template = await _save();
    if (mounted) context.pushReplacement('/play/${template.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bricks = draft.bricks;
    return FullPage(
      title: l.buildTitle,
      fallback: '/',
      maxWidth: 640,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: l.buildName),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: Space.xl),
          if (bricks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xl),
              child: Text(l.buildEmpty),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: (from, to) => _change(draft.move(from, to)),
              children: [
                for (var i = 0; i < bricks.length; i++)
                  Padding(
                    key: ValueKey(bricks[i].id),
                    padding: const EdgeInsets.only(bottom: Space.sm),
                    child: CompanionBrickRow(
                      brick: bricks[i],
                      onResize: (size) =>
                          _change(draft.replace(bricks[i].resized(size))),
                      onRemove: () => _change(draft.remove(bricks[i].id)),
                      onEarlier: i == 0
                          ? null
                          : () => _change(draft.move(i, i - 1)),
                      onLater: i == bricks.length - 1
                          ? null
                          : () => _change(draft.move(i, i + 1)),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.md,
            runSpacing: Space.md,
            children: [
              OutlinedButton.icon(
                onPressed: _add,
                icon: const DeckIcon(Icons.add),
                label: Text(l.buildAdd),
              ),
              OutlinedButton.icon(
                onPressed: _saveAndNotify,
                icon: const DeckIcon(Icons.save_outlined),
                label: Text(l.buildSave),
              ),
              FilledButton.icon(
                onPressed: bricks.isEmpty ? null : _launch,
                icon: const DeckIcon(Icons.play_arrow),
                label: Text(l.buildLaunch),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
