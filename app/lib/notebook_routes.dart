import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/dependencies.dart';
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
];
