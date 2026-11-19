import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/soundboard_tool.dart';

Widget soundboardWithStorage(BuildContext context) => SoundboardTool(
  sets: getIt<SoundSetUseCases>(),
  library: getIt<SoundLibraryGateway>(),
  engine: getIt<PlaylistEngine>(),
  pads: getIt<PadPlayer>(),
);

Widget soundboardForCampaign(String campaignId) => SoundboardTool(
  key: ValueKey(campaignId),
  sets: getIt<SoundSetUseCases>(),
  library: getIt<SoundLibraryGateway>(),
  engine: getIt<PlaylistEngine>(),
  pads: getIt<PadPlayer>(),
  ownerKind: SoundOwnerKind.campaign,
  ownerId: campaignId,
);
