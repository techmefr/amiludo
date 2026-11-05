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
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        context.l10n.sharingReceivedGamesPacksSheets(result.games, result.templates, result.characters),
      );
      context.go('/library');
    } catch (error) {
      if (mounted) notify(context, 'Import impossible : $error');
      setState(() => done = false);
    }
  }

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.sharingReceiveASession,
    fallback: '/library',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.sharingPointAtYourFriendS,
        ),
        const SizedBox(height: 16),
        QrScannerView(
          onCode: _frame,
          unavailable: context.l10n.sharingCameraUnavailableAskForThe,
        ),
        const SizedBox(height: 16),
        Semantics(
          label: context.l10n.sharingReceiveProgress,
          value: '${(decoder.progress * 100).round()} %',
          child: LinearProgressIndicator(value: decoder.progress),
        ),
        const SizedBox(height: 8),
        Text(
          decoder.count == 0
              ? context.l10n.sharingWaiting
              : '${decoder.solved} / ${decoder.count}',
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _file,
          child: Text(context.l10n.sharingOpenAFile),
        ),
      ],
    ),
  );
}
