import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key, required this.memory});

  final GameMemory memory;

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<MemoriesCubit>();
    try {
      final bytes = await FileTransfer.openImage();
      if (bytes != null) await cubit.addPhoto(memory.sessionId, bytes);
    } on FormatException catch (error) {
      if (context.mounted) notify(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        tr(
          context,
          'Les photos restent sur cet appareil. Pour les partager, la galerie est chiffrée et la clé se passe par QR code à la table.',
          'Photos stay on this device. To share them, the gallery is encrypted and the key is passed by QR code at the table.',
        ),
      ),
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
            label: Text(tr(context, 'Ajouter une photo', 'Add a photo')),
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
      tr(context, 'Supprimer la photo ?', 'Delete the photo?'),
      tr(context, 'Elle sera effacée de cet appareil.', 'It will be erased.'),
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
                  semanticLabel: tr(
                    context,
                    'Photo de la partie',
                    'Game photo',
                  ),
                ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton.filledTonal(
            tooltip: tr(context, 'Supprimer la photo', 'Delete photo'),
            onPressed: _remove,
            icon: const DeckIcon(Icons.delete_outline, size: 18),
          ),
        ),
      ],
    ),
  );
}
