import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_ids.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Templates/presentation/add_brick_picker.dart';
import 'package:amiludo/layers/functional/Templates/presentation/brick_label_dialog.dart';
import 'package:amiludo/layers/functional/Templates/presentation/builder_header.dart';
import 'package:amiludo/layers/functional/Templates/presentation/brick_settings_sheet.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_file_actions.dart';
import 'package:amiludo/layers/functional/Templates/presentation/saved_companions.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_list.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
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

  Future<void> _settings(Brick brick) async {
    if (brick.type == 'counter') {
      final next = await showBrickSettings(
        context,
        CounterSettings.fromJson(brick.settings),
      );
      if (next != null) _change(draft.replace(brick.withSettings(next.toJson())));
      return;
    }
    final label = await askBrickLabel(context, brick.label ?? '');
    if (label != null) _change(draft.replace(brick.labelled(label)));
  }

  Future<void> _export() async {
    final template = await _save();
    await shareCompanionFile(template);
  }

  Future<GameTemplate> _save() async {
    final base = existing ?? GameTemplate(id: id, name: name.text);
    final title = name.text.trim().isEmpty
        ? context.l10n.buildTitle
        : name.text.trim();
    final template = GameTemplate.fromJson({
      ...base.toJson(),
      'name': title,
      'englishName': title,
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
          const BuilderHeader(),
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: l.buildName),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: Space.xl),
          CompanionBrickList(
            draft: draft,
            onChanged: _change,
            onSettings: _settings,
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
              TextButton.icon(
                onPressed: bricks.isEmpty ? null : _export,
                icon: const DeckIcon(Icons.ios_share_outlined),
                label: Text(l.buildExport),
              ),
              TextButton.icon(
                onPressed: () => importCompanionFile(context),
                icon: const DeckIcon(Icons.file_download_outlined),
                label: Text(l.buildImport),
              ),
            ],
          ),
          SavedCompanions(
            companions: [
              for (final t in context.watch<TemplatesCubit>().state.templates)
                if (t.bricks.isNotEmpty && t.id != id) t,
            ],
            onEdit: (t) => context.pushReplacement('/build/${t.id}'),
            onPlay: (t) => context.push('/play/${t.id}'),
          ),
        ],
      ),
    );
  }
}
