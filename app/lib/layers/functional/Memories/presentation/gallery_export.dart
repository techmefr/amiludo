import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Qr/qr_code.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class GalleryExportButton extends StatefulWidget {
  const GalleryExportButton({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<GalleryExportButton> createState() => _GalleryExportButtonState();
}

class _GalleryExportButtonState extends State<GalleryExportButton> {
  bool busy = false;

  Future<void> _export() async {
    setState(() => busy = true);
    try {
      final export = await context.read<MemoriesCubit>().exportGallery(
        widget.sessionId,
      );
      await FileTransfer.shareText(export.fileText, export.filename);
      if (mounted) await _showKey(export.key);
    } catch (error) {
      if (mounted) notify(context, 'Export impossible : $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _showKey(String key) => showFormDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(tr(dialog, 'Clé de la galerie', 'Gallery key')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr(
                dialog,
                'Faites scanner ce code par vos amis. Sans lui, le fichier envoyé reste illisible.',
                'Let your friends scan this code. Without it, the file stays unreadable.',
              ),
            ),
            const SizedBox(height: 16),
            QrCode(
              data: key,
              size: 220,
              label: tr(dialog, 'QR code de la clé', 'Key QR code'),
            ),
            const SizedBox(height: 12),
            SelectableText(
              key,
              style: const TextStyle(fontFamily: 'IBMPlexMono'),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialog),
          child: Text(tr(dialog, 'Terminé', 'Done')),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: busy ? null : _export,
    icon: const DeckIcon(Icons.lock_outline, size: 18),
    label: Text(tr(context, 'Partager chiffrée', 'Share encrypted')),
  );
}
