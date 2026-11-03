import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Qr/qr_scanner_view.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class GalleryImportScreen extends StatefulWidget {
  const GalleryImportScreen({super.key});

  @override
  State<GalleryImportScreen> createState() => _GalleryImportScreenState();
}

class _GalleryImportScreenState extends State<GalleryImportScreen> {
  final key = TextEditingController();
  String? fileText;
  bool scanning = false, busy = false;

  @override
  void dispose() {
    key.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final text = await FileTransfer.openJson(maxMegabytes: 400);
      if (text != null) setState(() => fileText = text);
    } on FormatException catch (error) {
      if (mounted) notify(context, error.message);
    }
  }

  Future<void> _open() async {
    setState(() => busy = true);
    try {
      final id = await context.read<MemoriesCubit>().importGallery(
        fileText!,
        key.text,
      );
      if (mounted) context.go('/memories/$id');
    } catch (error) {
      if (mounted) notify(context, '$error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FullPage(
    title: tr(context, 'Ouvrir une galerie', 'Open a gallery'),
    fallback: '/history',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(
            context,
            '1. Choisissez le fichier reçu. 2. Scannez la clé affichée par votre ami.',
            '1. Pick the received file. 2. Scan the key shown by your friend.',
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _pick,
          child: Text(
            fileText == null
                ? tr(context, 'Choisir le fichier', 'Pick the file')
                : tr(context, 'Fichier prêt ✓', 'File ready ✓'),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: key,
          decoration: InputDecoration(
            labelText: tr(context, 'Clé de la galerie', 'Gallery key'),
            suffixIcon: IconButton(
              tooltip: tr(context, 'Scanner la clé', 'Scan the key'),
              onPressed: () => setState(() => scanning = !scanning),
              icon: const DeckIcon(Icons.qr_code_2),
            ),
          ),
        ),
        if (scanning) ...[
          const SizedBox(height: 16),
          QrScannerView(
            unavailable: tr(
              context,
              'Caméra indisponible. Saisissez la clé à la main.',
              'Camera unavailable. Type the key instead.',
            ),
            onCode: (code) => setState(() {
              key.text = code;
              scanning = false;
            }),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: fileText == null || busy ? null : _open,
          child: Text(tr(context, 'Déchiffrer', 'Decrypt')),
        ),
      ],
    ),
  );
}
