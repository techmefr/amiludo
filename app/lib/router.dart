import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/campaign_actions.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/campaign_screen.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/cubit/campaign_cubit.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_screen.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_tool.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/dice_studio.dart';
import 'package:amiludo/map_tool.dart';
import 'package:amiludo/notebook_routes.dart';
import 'package:amiludo/sensor_tools.dart';
import 'package:amiludo/layers/functional/Account/presentation/account_screen.dart';
import 'package:amiludo/layers/functional/Admin/presentation/admin_screen.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_detail.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_form.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_invite_screen.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evenings_screen.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/host_lobby_screen.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/join_screen.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/appearance_screen.dart';
import 'package:amiludo/layers/functional/Friends/presentation/friend_form.dart';
import 'package:amiludo/layers/functional/Friends/presentation/friends_screen.dart';
import 'package:amiludo/layers/functional/Friends/presentation/review_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/heroes_tool.dart';
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
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_view.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/sheet_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_page.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_use_cases.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/sheet_avatar.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_page.dart';
import 'package:amiludo/layers/functional/Random/presentation/tools_screen.dart';
import 'package:amiludo/layers/functional/Templates/presentation/builder_entry.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/marketplace_screen.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_builder.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_detail.dart';
import 'package:amiludo/layers/functional/Templates/presentation/templates_screen.dart';
import 'package:amiludo/layers/functional/Timer/presentation/timer_panel.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/app_shell.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/game_setup.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/home_screen.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/workspace_gate.dart';

Widget _timer(BuildContext context) =>
    const SizedBox(width: double.infinity, child: TimerPanel());

Widget _heroes(BuildContext context) => const HeroesTool();

Widget _scores(BuildContext context) => const GameScreen(timer: _timer);

Widget _counterLife(BuildContext context) =>
    CounterTool(settings: lifePreset, name: context.l10n.brickLife);

Widget _counterPoints(BuildContext context) =>
    CounterTool(settings: pointsPreset, name: context.l10n.brickPoints);

Widget _counterChips(BuildContext context) =>
    CounterTool(settings: chipsPreset, name: context.l10n.brickChips);

Widget _counterPot(BuildContext context) =>
    CounterTool(settings: potPreset, name: context.l10n.brickPot);

class _ToolsPage extends StatelessWidget {
  const _ToolsPage({this.initialTool});
  final String? initialTool;

  @override
  Widget build(BuildContext context) => ToolsScreen(
    key: ValueKey(initialTool),
    initialTool: initialTool,
    addBrick: context.read<TemplatesCubit>().addBrick,
  );
}

class _AdminPage extends StatelessWidget {
  const _AdminPage();

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        AdminCubit(getIt(), getIt(), getIt(), getIt(), getIt())..load(),
    child: const AdminScreen(),
  );
}

Widget _campaign(Widget child) => BlocProvider(
  create: (_) => CampaignCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  child: child,
);

GoRoute _page(String path, Widget Function(GoRouterState state) page) =>
    GoRoute(
      path: path,
      builder: (context, state) => WorkspaceGate(child: page(state)),
    );

class _ChroniclesRoute extends StatelessWidget {
  const _ChroniclesRoute();

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ChroniclesCubit(getIt(), getIt())..load(),
    child: ChroniclesPage(
      onSave: context.read<RandomCubit>().saveCharacter,
      sound: context.read<RandomCubit>().state.appearance.sound,
      haptics: context.read<RandomCubit>().state.appearance.haptics,
    ),
  );
}

class _SheetRoute extends StatelessWidget {
  const _SheetRoute(this.seed, this.pack);
  final SheetSeed? seed;
  final String? pack;

  CharacterSheet? _resumed(CharacterDraft? draft) {
    final raw = draft?.sheet;
    if (raw == null) return null;
    try {
      return CharacterSheet.fromJson(Map<String, dynamic>.from(raw));
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = context.read<RandomCubit>();
    final draft = pack == null ? null : random.draftFor(pack!);
    final resumed = seed?.initial == null ? _resumed(draft) : null;
    return BlocProvider(
      create: (_) =>
          SheetCubit(
            getIt<LoadSheetGeneratorUseCase>(),
            onChanged: draft == null
                ? null
                : (s) {
                    draft.sheet = s.toJson();
                    random.saveDraft(draft);
                  },
          )..load(
            universe: seed?.universe,
            kept: seed?.kept,
            initial: seed?.initial ?? resumed,
            reading: seed?.initial != null || seed?.kept != null,
          ),
      child: SheetPage(
        onSave: (character) async {
          await random.saveCharacter(character);
          if (draft != null) {
            draft.sheet = null;
            await random.saveDraft(draft);
          }
        },
        avatarEditor: editSheetAvatar,
        avatarPreview: sheetAvatarPreview,
      ),
    );
  }
}

final router = GoRouter(
  routes: [
    ...notebookRoutes,
    _page('/chronicles', (state) => const _ChroniclesRoute()),
    _page(
      '/character-sheet',
      (state) => _SheetRoute(
        state.extra is SheetSeed ? state.extra as SheetSeed : null,
        state.uri.queryParameters['pack'],
      ),
    ),
    _page(
      '/tools/:id',
      (state) => ToolPage(
        id: state.pathParameters['id']!,
        packId: state.uri.queryParameters['pack'],
        snapshot: state.uri.queryParameters['session'] == '1',
        embeddedTools: const {
          'scores': _scores,
          'timer': _timer,
          'dice-tray': diceTrayWithSensors,
          'hourglass': hourglassWithSensors,
          'map': mapWithStorage,
          'heroes': _heroes,
          'counter-life': _counterLife,
          'counter-points': _counterPoints,
          'counter-chips': _counterChips,
          'counter-pot': _counterPot,
        },
      ),
    ),
    GoRoute(path: '/timer', redirect: (context, state) => '/tools/timer'),
    _page('/dice/designs', (state) => diceLibraryPage()),
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
    _page('/campaign', (state) => _campaign(const CampaignScreen())),
    _page('/campaign/:id', (state) {
      final mission = campaignMissions
          .where((m) => m.id == state.pathParameters['id'])
          .firstOrNull;
      return _campaign(
        mission == null
            ? const CampaignScreen()
            : MissionScreen(mission: mission, actions: campaignActions),
      );
    }),
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
    _page('/lobby', (state) => const HostLobbyScreen()),
    _page('/join', (state) => const JoinScreen()),
    _page(
      '/join/:code',
      (state) => JoinScreen(
        initial: state.uri.queryParameters.isEmpty
            ? state.pathParameters['code']!
            : RoomLink(
                RoomKind.join,
                state.pathParameters['code']!,
                lan: state.uri.queryParameters['lan'],
                secret: state.uri.queryParameters['k'],
              ).appUri.toString(),
      ),
    ),
    _page('/account', (state) => const AccountScreen()),
    _page('/admin', (state) => const _AdminPage()),
    _page(
      '/evenings/edit/:id',
      (state) => EveningForm(id: state.pathParameters['id']!),
    ),
    _page(
      '/evenings/:id',
      (state) => EveningDetail(id: state.pathParameters['id']!),
    ),
    _page(
      '/evening/:code',
      (state) => EveningInviteScreen(code: state.pathParameters['code']!),
    ),
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
        (state) => _ToolsPage(initialTool: state.uri.queryParameters['tool']),
      ),
      ('/templates', (state) => const TemplatesScreen()),
      ('/library', (state) => const LibraryScreen()),
      ('/friends', (state) => const FriendsScreen()),
      ('/evenings', (state) => const EveningsScreen()),
      ('/history', (state) => const HistoryScreen()),
      ('/appearance', (state) => const AppearanceScreen()),
    ])
      GoRoute(
        path: path,
        builder: (context, state) =>
            AppShell(path: state.uri.path, child: screen(state)),
      ),
  ],
);
