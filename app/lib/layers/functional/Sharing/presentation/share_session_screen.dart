import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Sharing/domain/entities/session_bundle.dart';
import 'package:amiludo/layers/functional/Sharing/presentation/cubit/sharing_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Qr/qr_code.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Transfer/compression.dart';
import 'package:amiludo/layers/technical/Transfer/fountain.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class ShareSessionScreen extends StatefulWidget {
  const ShareSessionScreen({super.key, this.gameId, this.templateId});

  final String? gameId, templateId;

  @override
  State<ShareSessionScreen> createState() => _ShareSessionScreenState();
}

class _ShareSessionScreenState extends State<ShareSessionScreen> {
  late final games = <String>{?widget.gameId};
  late final templates = <String>{?widget.templateId};
  late SessionBundle bundle;
  late FountainEncoder encoder;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  void _rebuild() {
    bundle = context.read<SharingCubit>().bundle(
      shelfGameIds: games.toList(),
      templateIds: templates.toList(),
    );
    encoder = FountainEncoder(packJson(bundle.toJson()));
  }

  void _toggle(Set<String> set, String id, bool on) => setState(() {
    on ? set.add(id) : set.remove(id);
    _rebuild();
  });

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SharingCubit>().state;
    return FullPage(
      title: context.l10n.libraryShareASession,
      fallback: '/library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.sharingYourFriendOpensReceiveBy,
          ),
          SectionHeading(context.l10n.sharingContent),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in context.read<SharingCubit>().shelf)
                FilterChip(
                  label: Text(g.name),
                  selected: games.contains(g.id),
                  onSelected: (on) => _toggle(games, g.id, on),
                ),
              for (final t in data.templates)
                FilterChip(
                  avatar: const DeckIcon(Icons.style_outlined, size: 16),
                  label: Text(t.name),
                  selected: templates.contains(t.id),
                  onSelected: (on) => _toggle(templates, t.id, on),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (bundle.isEmpty)
            EmptyPanel(
              title: context.l10n.sharingNothingToShare,
              message: context.l10n.sharingPickAtLeastOneGame,
            )
          else
            _SharePreview(bundle: bundle, encoder: encoder),
        ],
      ),
    );
  }
}

class _SharePreview extends StatelessWidget {
  const _SharePreview({required this.bundle, required this.encoder});

  final SessionBundle bundle;
  final FountainEncoder encoder;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        AnimatedQr(
          key: ValueKey(encoder.id),
          frame: encoder.frame,
          label: context.l10n.sharingSessionQrCode,
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.sharingGamesPacksSheetsFrames(bundle.games.length, bundle.templates.length, bundle.characters.length, encoder.count),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => FileTransfer.shareText(
            jsonEncode(bundle.toJson()),
            'session-amiludo.json',
          ),
          child: Text(context.l10n.sharingSendAsAFile),
        ),
      ],
    ),
  );
}
