import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/appearance_screen.dart';
import 'package:amiludo/layers/functional/Friends/presentation/friend_form.dart';
import 'package:amiludo/layers/functional/Friends/presentation/friends_screen.dart';
import 'package:amiludo/layers/functional/Friends/presentation/review_screen.dart';
import 'package:amiludo/layers/functional/Game/presentation/game_screen.dart';
import 'package:amiludo/layers/functional/Game/presentation/score_sheet.dart';
import 'package:amiludo/layers/functional/History/presentation/history_screen.dart';
import 'package:amiludo/layers/functional/Library/presentation/library_screen.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_form.dart';
import 'package:amiludo/layers/functional/Library/presentation/tonight_screen.dart';
import 'package:amiludo/layers/functional/Memories/presentation/gallery_import_screen.dart';
import 'package:amiludo/layers/functional/Memories/presentation/memories_screen.dart';
import 'package:amiludo/layers/functional/Sharing/presentation/receive_session_screen.dart';
import 'package:amiludo/layers/functional/Sharing/presentation/share_session_screen.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_page.dart';
import 'package:amiludo/layers/functional/Random/presentation/tools_screen.dart';
import 'package:amiludo/layers/functional/Templates/presentation/builder_entry.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/marketplace_screen.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_builder.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_detail.dart';
import 'package:amiludo/layers/functional/Templates/presentation/templates_screen.dart';
import 'package:amiludo/layers/functional/Timer/presentation/timer_panel.dart';
import 'package:amiludo/layers/functional/Timer/presentation/timer_screen.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/app_shell.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/game_setup.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/home_screen.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/workspace_gate.dart';

Widget _timer(BuildContext context) => const TimerPanel();

Widget _scores(BuildContext context) => const GameScreen(timer: _timer);

GoRoute _page(String path, Widget Function(GoRouterState state) page) =>
    GoRoute(
      path: path,
      builder: (context, state) => WorkspaceGate(child: page(state)),
    );

final router = GoRouter(
  routes: [
    _page(
      '/tools/:id',
      (state) => ToolPage(
        id: state.pathParameters['id']!,
        packId: state.uri.queryParameters['pack'],
        snapshot: state.uri.queryParameters['session'] == '1',
        embeddedTools: const {'scores': _scores, 'timer': _timer},
      ),
    ),
    _page('/builder/new', (state) => const PackBuilder()),
    _page(
      '/builder/:id',
      (state) => BuilderEntry(id: state.pathParameters['id']!),
    ),
    _page(
      '/pack/:id',
      (state) => PackDetail(
        id: state.pathParameters['id']!,
        snapshot: state.uri.queryParameters['session'] == '1',
      ),
    ),
    _page(
      '/marketplace',
      (state) => BlocProvider(
        create: (_) => MarketplaceCubit(getIt(), getIt())..loadBundled(),
        child: const MarketplaceScreen(),
      ),
    ),
    _page(
      '/score/:player',
      (state) => ScoreSheet(playerId: state.pathParameters['player']!),
    ),
    _page('/library/tonight', (state) => const TonightScreen()),
    _page(
      '/library/edit/:id',
      (state) => ShelfGameForm(id: state.pathParameters['id']!),
    ),
    _page(
      '/friends/edit/:id',
      (state) => FriendForm(id: state.pathParameters['id']!),
    ),
    _page(
      '/review/:sessionId',
      (state) => ReviewScreen(sessionId: state.pathParameters['sessionId']!),
    ),
    _page('/memories/import', (state) => const GalleryImportScreen()),
    _page(
      '/memories/:sessionId',
      (state) => MemoriesScreen(sessionId: state.pathParameters['sessionId']!),
    ),
    _page(
      '/share',
      (state) => ShareSessionScreen(
        gameId: state.uri.queryParameters['game'],
        templateId: state.uri.queryParameters['pack'],
      ),
    ),
    _page('/share/receive', (state) => const ReceiveSessionScreen()),
    _page(GameSetupRequest.path, (state) {
      final request = state.extra is GameSetupRequest
          ? state.extra! as GameSetupRequest
          : const GameSetupRequest();
      return GameSetupPage(template: request.template, names: request.names);
    }),
    for (final (path, screen) in <(String, Widget Function(GoRouterState))>[
      ('/', (state) => const HomeScreen()),
      ('/game', (state) => const GameScreen(timer: _timer)),
      (
        '/tools',
        (state) => ToolsScreen(
          key: ValueKey(state.uri.queryParameters['tool']),
          initialTool: state.uri.queryParameters['tool'],
        ),
      ),
      ('/templates', (state) => const TemplatesScreen()),
      ('/library', (state) => const LibraryScreen()),
      ('/friends', (state) => const FriendsScreen()),
      ('/history', (state) => const HistoryScreen()),
      ('/appearance', (state) => const AppearanceScreen()),
      ('/timer', (state) => const TimerScreen()),
    ])
      GoRoute(
        path: path,
        builder: (context, state) =>
            AppShell(path: state.uri.path, child: screen(state)),
      ),
  ],
);
