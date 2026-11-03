import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Sharing/domain/entities/session_bundle.dart';
import 'package:amiludo/layers/functional/Sharing/presentation/cubit/sharing_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Qr/qr_scanner_view.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Transfer/compression.dart';
import 'package:amiludo/layers/technical/Transfer/fountain.dart';

class ReceiveSessionScreen extends StatefulWidget {
  const ReceiveSessionScreen({super.key});

  @override
  State<ReceiveSessionScreen> createState() => _ReceiveSessionScreenState();
}

class _ReceiveSessionScreenState extends State<ReceiveSessionScreen> {
  final decoder = FountainDecoder();
  bool done = false;

  void _frame(String code) {
    if (done || !decoder.add(code)) return;
    setState(() {});
    final bytes = decoder.bytes;
    if (bytes == null) return;
    done = true;
    _import(() => unpackJson(bytes));
  }

  Future<void> _file() async {
    try {
      final text = await FileTransfer.openJson();
      if (text != null) await _import(() => jsonDecode(text));
    } on FormatException catch (error) {
      if (mounted) notify(context, error.message);
    }
  }

  Future<void> _import(Object? Function() read) async {
    final cubit = context.read<SharingCubit>();
    try {
      final bundle = SessionBundle.fromJson(
        Map<String, dynamic>.from(read()! as Map),
      );
      final result = await cubit.receive(bundle);
      if (!mounted) return;
      notify(
        context,
        tr(
          context,
          'Reçu : ${result.games} jeux, ${result.templates} packs, ${result.characters} fiches',
          'Received: ${result.games} games, ${result.templates} packs, ${result.characters} sheets',
        ),
      );
      context.go('/library');
    } catch (error) {
      if (mounted) notify(context, 'Import impossible : $error');
      setState(() => done = false);
    }
  }

  @override
  Widget build(BuildContext context) => FullPage(
    title: tr(context, 'Recevoir une session', 'Receive a session'),
    fallback: '/library',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(
            context,
            'Visez le QR code animé de votre ami et gardez l’écran dans le cadre jusqu’à 100 %.',
            'Point at your friend’s animated QR code and keep it framed until 100%.',
          ),
        ),
        const SizedBox(height: 16),
        QrScannerView(
          onCode: _frame,
          unavailable: tr(
            context,
            'Caméra indisponible. Demandez plutôt le fichier.',
            'Camera unavailable. Ask for the file instead.',
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: tr(context, 'Progression de la réception', 'Receive progress'),
          value: '${(decoder.progress * 100).round()} %',
          child: LinearProgressIndicator(value: decoder.progress),
        ),
        const SizedBox(height: 8),
        Text(
          decoder.count == 0
              ? tr(context, 'En attente du premier code…', 'Waiting…')
              : '${decoder.solved} / ${decoder.count}',
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _file,
          child: Text(tr(context, 'Ouvrir un fichier reçu', 'Open a file')),
        ),
      ],
    ),
  );
}
