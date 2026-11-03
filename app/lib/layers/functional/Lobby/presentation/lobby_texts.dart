import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

String lobbyErrorText(
  BuildContext context,
  LobbyError error,
) => switch (error) {
  LobbyError.invalid => tr(
    context,
    'Vérifiez le code et votre prénom.',
    'Check the code and your name.',
  ),
  LobbyError.notFound => tr(
    context,
    'Aucune partie ouverte avec ce code. L’hôte a-t-il bien ouvert le salon ?',
    'No open game with this code. Has the host opened the lobby?',
  ),
  LobbyError.unreachable => tr(
    context,
    'Connexion impossible : rapprochez-vous du même Wi-Fi ou activez Internet.',
    'Cannot connect: join the same Wi-Fi or turn on Internet.',
  ),
  LobbyError.failed => tr(
    context,
    'Quelque chose a échoué, réessayez.',
    'Something went wrong, try again.',
  ),
};
