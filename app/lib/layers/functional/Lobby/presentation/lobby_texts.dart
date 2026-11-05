import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

String lobbyErrorText(
  BuildContext context,
  LobbyError error,
) => switch (error) {
  LobbyError.invalid => context.l10n.lobbyCheckTheCodeAndYour,
  LobbyError.notFound => context.l10n.lobbyNoOpenGameWithThis,
  LobbyError.unreachable => context.l10n.lobbyCannotConnectJoinTheSame,
  LobbyError.failed => context.l10n.lobbySomethingWentWrongTryAgain,
};
