import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class LobbyMembers extends StatelessWidget {
  const LobbyMembers({super.key, required this.lobby, this.host = false});

  final Lobby lobby;
  final bool host;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeading(
        context.l10n.lobbyPlayers(lobby.playerNames.length, lobby.seats),
      ),
      ListTile(
        leading: const Icon(Icons.star),
        title: Text(lobby.hostName),
        subtitle: Text(context.l10n.lobbyHost),
      ),
      for (final seat in lobby.accepted) _SeatTile(seat: seat, host: host),
      if (host && lobby.pending.isNotEmpty) ...[
        SectionHeading(context.l10n.lobbyRequests),
        for (final seat in lobby.pending)
          _SeatTile(seat: seat, host: host, full: lobby.full),
      ],
    ],
  );
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({required this.seat, required this.host, this.full = false});

  final LobbySeat seat;
  final bool host, full;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LobbyCubit>();
    final pending = seat.status == SeatStatus.pending;
    return ListTile(
      leading: CircleAvatar(backgroundColor: Color(seat.color)),
      title: Text(seat.name),
      subtitle: pending ? Text(context.l10n.lobbyWantsToJoin) : null,
      trailing: !host
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pending)
                  IconButton(
                    tooltip: full
                        ? context.l10n.lobbyNoSeatLeft
                        : context.l10n.lobbyAccept(seat.name),
                    onPressed: full
                        ? null
                        : () => cubit.decide(seat.id, accept: true),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                IconButton(
                  tooltip: pending
                      ? context.l10n.lobbyRefuse(seat.name)
                      : context.l10n.lobbyRemove(seat.name),
                  onPressed: () => cubit.decide(seat.id, accept: false),
                  icon: const Icon(Icons.cancel_outlined),
                ),
              ],
            ),
    );
  }
}
