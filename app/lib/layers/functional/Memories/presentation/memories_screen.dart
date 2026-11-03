import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/functional/Memories/presentation/gallery_export.dart';
import 'package:amiludo/layers/functional/Memories/presentation/photo_grid.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MemoriesCubit>().state;
    final game = data.games.where((g) => g.id == sessionId).firstOrNull;
    final memory = data.memoryOf(sessionId);
    return FullPage(
      title: tr(context, 'Souvenirs', 'Memories'),
      fallback: '/history',
      child: game == null
          ? EmptyPanel(
              title: tr(context, 'Partie introuvable', 'Game not found'),
              message: tr(
                context,
                'Elle a peut-être été supprimée.',
                'It may have been deleted.',
              ),
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
                SectionHeading(tr(context, 'Le récit', 'The story')),
                _NoteField(memory: memory),
                SectionHeading(tr(context, 'Moments forts', 'Highlights')),
                _Highlights(memory: memory),
                SectionHeading(
                  tr(context, 'Galerie privée', 'Private gallery'),
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
      notify(context, tr(context, 'Récit enregistré', 'Story saved'));
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
          labelText: tr(
            context,
            'Ce qu’on retiendra de cette soirée',
            'What we’ll remember of this night',
          ),
        ),
      ),
      OutlinedButton(
        onPressed: _save,
        child: Text(tr(context, 'Enregistrer le récit', 'Save the story')),
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
            tooltip: tr(context, 'Retirer ce moment', 'Remove this moment'),
            onPressed: () => _remove(context, h),
            icon: const DeckIcon(Icons.close, size: 18),
          ),
        ),
      TextField(
        maxLength: 280,
        decoration: InputDecoration(
          labelText: tr(
            context,
            'Un moment fort, puis Entrée',
            'A highlight, then Enter',
          ),
        ),
        onSubmitted: (v) => _add(context, v),
      ),
    ],
  );
}
