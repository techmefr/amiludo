import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Qr/qr_scanner_view.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
    title: context.l10n.memoriesOpenAGallery,
    fallback: '/history',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.memories1PickTheReceivedFile,
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _pick,
          child: Text(
            fileText == null
                ? context.l10n.memoriesPickTheFile
                : context.l10n.memoriesFileReady,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: key,
          decoration: InputDecoration(
            labelText: context.l10n.memoriesGalleryKey,
            suffixIcon: IconButton(
              tooltip: context.l10n.memoriesScanTheKey,
              onPressed: () => setState(() => scanning = !scanning),
              icon: const DeckIcon(Icons.qr_code_2),
            ),
          ),
        ),
        if (scanning) ...[
          const SizedBox(height: 16),
          QrScannerView(
            unavailable: context.l10n.memoriesCameraUnavailableTypeTheKey,
            onCode: (code) => setState(() {
              key.text = code;
              scanning = false;
            }),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: fileText == null || busy ? null : _open,
          child: Text(context.l10n.memoriesDecrypt),
        ),
      ],
    ),
  );
}
