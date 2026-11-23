import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_share.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';
import 'package:amiludo/lobby_sound_transport.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/soundboard_tool.dart';

SoundShare? _share() => getIt.isRegistered<LobbyGateway>()
    ? soundShareForLobby(getIt<LobbyGateway>(), getIt<SoundBlobGateway>())
    : null;

Widget soundboardWithStorage(BuildContext context) => SoundboardTool(
  sets: getIt<SoundSetUseCases>(),
  library: getIt<SoundLibraryGateway>(),
  engine: getIt<PlaylistEngine>(),
  pads: getIt<PadPlayer>(),
  share: _share(),
  blobs: getIt<SoundBlobGateway>(),
  output: getIt<ClipOutput>(),
);

Widget soundboardForGame(String brickId) => SoundboardTool(
  key: ValueKey(brickId),
  sets: getIt<SoundSetUseCases>(),
  library: getIt<SoundLibraryGateway>(),
  engine: getIt<PlaylistEngine>(),
  pads: getIt<PadPlayer>(),
  share: _share(),
  blobs: getIt<SoundBlobGateway>(),
  output: getIt<ClipOutput>(),
  ownerKind: SoundOwnerKind.game,
  ownerId: brickId,
);

Widget soundboardForCampaign(String campaignId) => SoundboardTool(
  key: ValueKey(campaignId),
  sets: getIt<SoundSetUseCases>(),
  library: getIt<SoundLibraryGateway>(),
  engine: getIt<PlaylistEngine>(),
  pads: getIt<PadPlayer>(),
  share: _share(),
  blobs: getIt<SoundBlobGateway>(),
  output: getIt<ClipOutput>(),
  ownerKind: SoundOwnerKind.campaign,
  ownerId: campaignId,
);
