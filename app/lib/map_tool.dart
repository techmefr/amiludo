import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_boards.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/map_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/map_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';

Widget mapWithStorage(BuildContext context) {
  if (!getIt.isRegistered<MapBoardsGateway>()) return const MapBoardTool();
  final key = context.read<RandomCubit>().state.currentId ?? freeMapKey;
  final save = getIt<SaveMapUseCase>();
  return MapBoardTool(
    key: ValueKey(key),
    initial: getIt<ReadMapUseCase>()(key),
    onChanged: (board) => save(key, board),
    importImage: getIt<ImportMapImageUseCase>().call,
    readImage: getIt<ReadMapImageUseCase>().call,
  );
}
