import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/functional/Memories/presentation/gallery_export.dart';
import 'package:amiludo/layers/functional/Memories/presentation/photo_grid.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MemoriesCubit>();
    final data = cubit.state;
    final game = cubit.session(sessionId);
    final memory = data.memoryOf(sessionId);
    return FullPage(
      title: context.l10n.historyMemories,
      fallback: '/history',
      child: game == null
          ? EmptyPanel(
              title: context.l10n.friendsGameNotFound,
              message: context.l10n.friendsItMayHaveBeenDeleted,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateTime.fromMillisecondsSinceEpoch(game.createdAt).toLocal().toString().substring(0, 16)} · ${game.players.map((p) => p.name).join(', ')}',
                ),
                SectionHeading(context.l10n.memoriesTheStory),
                _NoteField(memory: memory),
                SectionHeading(context.l10n.memoriesHighlights),
                _Highlights(memory: memory),
                SectionHeading(
                  context.l10n.memoriesPrivateGallery,
                  action: GalleryExportButton(sessionId: sessionId),
                ),
                PhotoGrid(memory: memory),
              ],
            ),
    );
  }
}

class _NoteField extends StatefulWidget {
  const _NoteField({required this.memory});

  final GameMemory memory;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final controller = TextEditingController(text: widget.memory.note);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<MemoriesCubit>();
    await cubit.save(
      cubit.state
          .memoryOf(widget.memory.sessionId)
          .copyWith(note: controller.text.trim()),
    );
    if (mounted) {
      notify(context, context.l10n.memoriesStorySaved);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        minLines: 3,
        maxLines: 10,
        maxLength: 4000,
        decoration: InputDecoration(
          labelText: context.l10n.memoriesWhatWeLlRememberOf,
        ),
      ),
      OutlinedButton(
        onPressed: _save,
        child: Text(context.l10n.memoriesSaveTheStory),
      ),
    ],
  );
}

class _Highlights extends StatelessWidget {
  const _Highlights({required this.memory});

  final GameMemory memory;

  Future<void> _add(BuildContext context, String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    final cubit = context.read<MemoriesCubit>();
    final current = cubit.state.memoryOf(memory.sessionId);
    await cubit.save(
      current.copyWith(
        highlights: [
          ...current.highlights,
          Highlight(
            id: newId(),
            text: value.length > 280 ? value.substring(0, 280) : value,
            at: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
      ),
    );
  }

  Future<void> _remove(BuildContext context, Highlight highlight) {
    final cubit = context.read<MemoriesCubit>();
    final current = cubit.state.memoryOf(memory.sessionId);
    return cubit.save(
      current.copyWith(
        highlights: current.highlights
            .where((h) => h.id != highlight.id)
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final h in memory.highlights)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const DeckIcon(Icons.star_outline, size: 20),
          title: Text(h.text),
          trailing: IconButton(
            tooltip: context.l10n.memoriesRemoveThisMoment,
            onPressed: () => _remove(context, h),
            icon: const DeckIcon(Icons.close, size: 18),
          ),
        ),
      TextField(
        maxLength: 280,
        decoration: InputDecoration(
          labelText: context.l10n.memoriesAHighlightThenEnter,
        ),
        onSubmitted: (v) => _add(context, v),
      ),
    ],
  );
}
