import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/lobby_members.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/lobby_texts.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/technical/Qr/qr_scanner_view.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key, this.initial});

  final String? initial;

  @override
  Widget build(BuildContext context) => FullPage(
    title: tr(context, 'Rejoindre', 'Join'),
    fallback: '/',
    child: BlocBuilder<LobbyCubit, LobbyState>(
      builder: (context, state) {
        final session = state.session;
        if (session == null || session.isHost) {
          return _JoinForm(state: state, initial: initial);
        }
        return _GuestView(session: session);
      },
    ),
  );
}

class _JoinForm extends StatefulWidget {
  const _JoinForm({required this.state, this.initial});

  final LobbyState state;
  final String? initial;

  @override
  State<_JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<_JoinForm> {
  late final name = TextEditingController(
    text: context.read<LobbyCubit>().nickname,
  );
  late final code = TextEditingController(text: widget.initial ?? '');
  bool scanning = false;

  @override
  void dispose() {
    name.dispose();
    code.dispose();
    super.dispose();
  }

  void _submit([String? scanned]) {
    final input = scanned ?? code.text;
    if (scanned != null) setState(() => scanning = false);
    final link = RoomLink.parse(input);
    if (link?.kind == RoomKind.evening) {
      context.go(link!.route);
      return;
    }
    if (name.text.trim().isEmpty) {
      notify(context, tr(context, 'Indiquez votre prénom', 'Enter your name'));
      return;
    }
    context.read<LobbyCubit>().join(input, name: name.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: name,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: tr(context, 'Votre prénom', 'Your name'),
          ),
        ),
        TextField(
          controller: code,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: tr(context, 'Code ou lien', 'Code or link'),
            hintText: 'ABC 123',
          ),
          onSubmitted: (_) => _submit(),
        ),
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Text(
            lobbyErrorText(context, state.error!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: state.busy ? null : _submit,
              icon: state.busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(tr(context, 'Rejoindre', 'Join')),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => scanning = !scanning),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(tr(context, 'Scanner un QR', 'Scan a QR')),
            ),
          ],
        ),
        if (scanning) ...[
          const SizedBox(height: 16),
          QrScannerView(
            onCode: _submit,
            unavailable: tr(
              context,
              'Caméra indisponible : tapez le code.',
              'Camera unavailable: type the code.',
            ),
          ),
        ],
      ],
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.session});

  final LobbySession session;

  String _status(BuildContext context) {
    final lobby = session.lobby;
    if (session.ended) {
      return tr(
        context,
        'L’hôte a fermé le salon.',
        'The host closed the lobby.',
      );
    }
    return switch (session.myStatus) {
      SeatStatus.accepted when lobby.started => tr(
        context,
        'C’est parti ! La partie se joue chez ${lobby.hostName}.',
        'Here we go! The game runs on ${lobby.hostName}’s device.',
      ),
      SeatStatus.accepted => tr(
        context,
        'Vous êtes dans la partie. Attendez le lancement.',
        'You are in. Wait for the start.',
      ),
      SeatStatus.refused => tr(
        context,
        'L’hôte n’a pas accepté votre demande.',
        'The host did not accept your request.',
      ),
      _ => tr(
        context,
        'Demande envoyée à ${lobby.hostName}…',
        'Request sent to ${lobby.hostName}…',
      ),
    };
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DeckPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.lobby.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Semantics(liveRegion: true, child: Text(_status(context))),
          ],
        ),
      ),
      LobbyMembers(lobby: session.lobby),
      const SizedBox(height: 24),
      OutlinedButton(
        onPressed: context.read<LobbyCubit>().leave,
        child: Text(tr(context, 'Quitter', 'Leave')),
      ),
    ],
  );
}
