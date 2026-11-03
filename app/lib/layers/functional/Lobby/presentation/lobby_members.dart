import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class LobbyMembers extends StatelessWidget {
  const LobbyMembers({super.key, required this.lobby, this.host = false});

  final Lobby lobby;
  final bool host;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeading(
        tr(
          context,
          'Joueurs ${lobby.playerNames.length}/${lobby.seats}',
          'Players ${lobby.playerNames.length}/${lobby.seats}',
        ),
      ),
      ListTile(
        leading: const Icon(Icons.star),
        title: Text(lobby.hostName),
        subtitle: Text(tr(context, 'Hôte', 'Host')),
      ),
      for (final seat in lobby.accepted) _SeatTile(seat: seat, host: host),
      if (host && lobby.pending.isNotEmpty) ...[
        SectionHeading(tr(context, 'Demandes', 'Requests')),
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
      subtitle: pending
          ? Text(tr(context, 'Veut rejoindre', 'Wants to join'))
          : null,
      trailing: !host
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pending)
                  IconButton(
                    tooltip: full
                        ? tr(context, 'Plus de place', 'No seat left')
                        : tr(
                            context,
                            'Accepter ${seat.name}',
                            'Accept ${seat.name}',
                          ),
                    onPressed: full
                        ? null
                        : () => cubit.decide(seat.id, accept: true),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                IconButton(
                  tooltip: pending
                      ? tr(
                          context,
                          'Refuser ${seat.name}',
                          'Refuse ${seat.name}',
                        )
                      : tr(
                          context,
                          'Retirer ${seat.name}',
                          'Remove ${seat.name}',
                        ),
                  onPressed: () => cubit.decide(seat.id, accept: false),
                  icon: const Icon(Icons.cancel_outlined),
                ),
              ],
            ),
    );
  }
}
