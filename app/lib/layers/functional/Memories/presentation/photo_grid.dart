import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key, required this.memory});

  final GameMemory memory;

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<MemoriesCubit>();
    try {
      final bytes = await FileTransfer.openImage();
      if (bytes != null) await cubit.addPhoto(memory.sessionId, bytes);
    } on PhotoError catch (error) {
      if (context.mounted) notify(context, _photoErrorText(context, error));
    } on FormatException catch (error) {
      if (context.mounted) notify(context, error.message);
    }
  }

  String _photoErrorText(BuildContext context, PhotoError error) =>
      switch (error) {
        PhotoError.tooLarge => context.l10n.memoriesPhotoTooLarge8Mb,
        PhotoError.tooMany => context.l10n.memories60PhotosMaximumPerGame,
      };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.l10n.memoriesPhotosStayOnThisDevice),
      const SizedBox(height: 16),
      ResponsiveGrid(
        minimumWidth: 140,
        gap: 8,
        children: [
          for (final id in memory.photoIds)
            _Photo(sessionId: memory.sessionId, id: id),
          OutlinedButton.icon(
            onPressed: () => _add(context),
            icon: const DeckIcon(Icons.add_photo_alternate_outlined),
            label: Text(context.l10n.memoriesAddAPhoto),
          ),
        ],
      ),
    ],
  );
}

class _Photo extends StatefulWidget {
  const _Photo({required this.sessionId, required this.id});

  final String sessionId, id;

  @override
  State<_Photo> createState() => _PhotoState();
}

class _PhotoState extends State<_Photo> {
  late final Future<Uint8List?> bytes = context.read<MemoriesCubit>().readPhoto(
    widget.id,
  );

  Future<void> _remove() async {
    final cubit = context.read<MemoriesCubit>();
    if (await confirm(
      context,
      context.l10n.memoriesDeleteThePhoto,
      context.l10n.memoriesItWillBeErased,
    )) {
      await cubit.removePhoto(widget.sessionId, widget.id);
    }
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: Stack(
      fit: StackFit.expand,
      children: [
        FutureBuilder(
          future: bytes,
          builder: (context, snapshot) => snapshot.data == null
              ? ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                )
              : Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  semanticLabel: context.l10n.memoriesGamePhoto,
                ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton.filledTonal(
            tooltip: context.l10n.memoriesDeletePhoto,
            onPressed: _remove,
            icon: const DeckIcon(Icons.delete_outline, size: 18),
          ),
        ),
      ],
    ),
  );
}
