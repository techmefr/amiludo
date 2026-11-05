import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/lobby_members.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/lobby_texts.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/technical/Qr/invite_card.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class HostLobbyScreen extends StatelessWidget {
  const HostLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.workspaceOpenALobby,
    fallback: '/',
    child: BlocBuilder<LobbyCubit, LobbyState>(
      builder: (context, state) {
        final session = state.session;
        if (session == null || !session.isHost) return _LobbyForm(state: state);
        return _OpenLobby(lobby: session.lobby, link: session.link);
      },
    ),
  );
}

class _LobbyForm extends StatefulWidget {
  const _LobbyForm({required this.state});

  final LobbyState state;

  @override
  State<_LobbyForm> createState() => _LobbyFormState();
}

class _LobbyFormState extends State<_LobbyForm> {
  late final name = TextEditingController(
    text: context.read<LobbyCubit>().nickname,
  );
  final title = TextEditingController();
  int seats = 4;
  late bool lan = widget.state.lanSupported;
  late bool remote = widget.state.remoteSupported;

  @override
  void dispose() {
    name.dispose();
    title.dispose();
    super.dispose();
  }

  void _open() => context.read<LobbyCubit>().host(
    title: title.text,
    name: name.text,
    seats: seats,
    lan: lan,
    remote: remote,
  );

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: name,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: context.l10n.accountYourName,
          ),
        ),
        TextField(
          controller: title,
          maxLength: 60,
          decoration: InputDecoration(
            labelText: context.l10n.workspaceGameName,
            hintText: context.l10n.lobbySkullNight,
          ),
        ),
        SectionHeading(context.l10n.lobbySeats(seats)),
        Slider(
          min: 2,
          max: 12,
          divisions: 10,
          value: seats.toDouble(),
          label: '$seats',
          onChanged: (v) => setState(() => seats = v.round()),
        ),
        _ReachSwitches(
          state: state,
          lan: lan,
          remote: remote,
          onLan: (v) => setState(() => lan = v),
          onRemote: (v) => setState(() => remote = v),
        ),
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Text(
            lobbyErrorText(context, state.error!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: state.busy || !(lan || remote) ? null : _open,
          icon: const Icon(Icons.wifi_tethering),
          label: Text(context.l10n.lobbyOpenTheLobby),
        ),
      ],
    );
  }
}

class _ReachSwitches extends StatelessWidget {
  const _ReachSwitches({
    required this.state,
    required this.lan,
    required this.remote,
    required this.onLan,
    required this.onRemote,
  });

  final LobbyState state;
  final bool lan, remote;
  final ValueChanged<bool> onLan, onRemote;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SwitchListTile(
        value: lan && state.lanSupported,
        onChanged: state.lanSupported ? onLan : null,
        title: Text(context.l10n.lobbySameWiFi),
        subtitle: Text(
          state.lanSupported
              ? context.l10n.lobbyAroundTheTableNoServer
              : context.l10n.lobbyNotAvailableInTheBrowser,
        ),
      ),
      SwitchListTile(
        value: remote && state.remoteSupported,
        onChanged: state.remoteSupported ? onRemote : null,
        title: Text(context.l10n.lobbyRemote),
        subtitle: Text(
          state.remoteSupported
              ? context.l10n.lobbyOverTheInternetWithThe
              : context.l10n.lobbyNoServerConfiguredForThis,
        ),
      ),
    ],
  );
}

class _OpenLobby extends StatelessWidget {
  const _OpenLobby({required this.lobby, required this.link});

  final Lobby lobby;
  final RoomLink link;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LobbyCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InviteCard(link: link, title: lobby.title),
        SwitchListTile(
          value: lobby.open,
          onChanged: (_) => cubit.toggleOpen(),
          title: Text(context.l10n.lobbyAcceptRequests),
        ),
        LobbyMembers(lobby: lobby, host: true),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () {
                final names = cubit.start();
                context.go(
                  GameSetupRequest.path,
                  extra: GameSetupRequest(names: names),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                context.l10n.lobbyStartWithPlayers(lobby.playerNames.length),
              ),
            ),
            OutlinedButton(
              onPressed: cubit.leave,
              child: Text(context.l10n.lobbyCloseTheLobby),
            ),
          ],
        ),
      ],
    );
  }
}
