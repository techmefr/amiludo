import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/map_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_tool.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/atlas_map_screen.dart';
import 'package:amiludo/layers/functional/Notebook/domain/use_cases/notebook_use_cases.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaigns_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/notebook_images.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/workspace_gate.dart';

Widget _notebook(Widget child) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider(
      create: (_) => NotebookImages(
        importImage: getIt<ImportNotebookImageUseCase>().call,
        readImage: getIt<ReadNotebookImageUseCase>().call,
      ),
    ),
    BlocProvider(
      create: (_) =>
          NotebookCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()),
    ),
  ],
  child: child,
);

GoRoute _route(String path, Widget Function(GoRouterState state) page) =>
    GoRoute(
      path: path,
      builder: (context, state) => WorkspaceGate(child: _notebook(page(state))),
    );

final notebookRoutes = [
  _route('/notebook', (state) => const CampaignsScreen()),
  _route(
    '/notebook/:id',
    (state) => CampaignScreen(id: state.pathParameters['id']!),
  ),
  _route(
    '/notebook/:id/entry/:entry',
    (state) => EntryScreen(
      campaignId: state.pathParameters['id']!,
      entryId: state.pathParameters['entry']!,
    ),
  ),
  _route(
    '/notebook/:id/map/:place',
    (state) => AtlasMapScreen(
      key: ValueKey(state.pathParameters['place']),
      campaignId: state.pathParameters['id']!,
      placeId: state.pathParameters['place']!,
      readBoard: getIt<ReadMapUseCase>().call,
      buildMap: _atlasMap,
    ),
  ),
];

Widget _atlasMap(
  BuildContext context,
  String mapKey,
  ValueChanged<MapBoard> onChanged,
) {
  final save = getIt<SaveMapUseCase>();
  return MapBoardTool(
    key: ValueKey(mapKey),
    initial: getIt<ReadMapUseCase>()(mapKey),
    onChanged: (board) {
      save(mapKey, board);
      onChanged(board);
    },
    importImage: getIt<ImportMapImageUseCase>().call,
    readImage: getIt<ReadMapImageUseCase>().call,
  );
}
