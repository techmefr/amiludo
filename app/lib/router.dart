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
import 'package:amiludo/layers/functional/Companion/presentation/chess_clock_tool.dart';
import 'package:amiludo/combat_tool.dart';
import 'package:amiludo/bestiary_tool.dart';
import 'package:amiludo/scenes_tool.dart';
import 'package:amiludo/tables_tool.dart';
import 'package:amiludo/world_tool.dart';
import 'package:amiludo/rules_tool.dart';
import 'package:amiludo/journal_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/oracle_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/challenges_tool.dart';
import 'package:amiludo/ambience_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/impostor_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/deck_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/vote_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/first_player_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/buzzer_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/auction_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/league_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/solo_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/units_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/balance_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/bank_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/clocks_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tournament_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/markers_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/sport_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/ranking_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/sheet_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/stats_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/stopwatch_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tally_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/turns_tool.dart';
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
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/barcode_scan_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/library_screen.dart';
import 'package:amiludo/layers/functional/Library/presentation/scan_barcode_screen.dart';
import 'package:amiludo/layers/technical/Barcode/barcode_scanner_view.dart';
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
import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/builder_entry.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_builder.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_session.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
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

Widget _stopwatch(BuildContext context) => const StopwatchTool();

Widget _chessClock(BuildContext context) => const ChessClockTool();
Widget _deck(BuildContext context) => const DeckTool();

Widget _vote(BuildContext context) => const VoteTool();
List<String> _names(BuildContext context) {
  final workspace = context.read<RandomCubit>().state;
  final names =
      workspace.current?.players.map((p) => p.name).toList() ??
      workspace.playerNames;
  return names.isEmpty ? const ['1', '2'] : names;
}

Widget _life(BuildContext context) => LifeTool(names: _names(context));

Widget _tally(BuildContext context) => TallyTool(names: _names(context));

Widget _ranking(BuildContext context) => RankingTool(names: _names(context));

Widget _sheet(BuildContext context) => SheetTool(names: _names(context));

Widget _buzzer(BuildContext context) => BuzzerTool(names: _names(context));

Widget _stats(BuildContext context) =>
    StatsTool(games: context.read<RandomCubit>().state.games);

Widget _clocks(BuildContext context) => const ClocksTool();

Widget _sport(BuildContext context) => SportTool(names: _names(context));

Widget _markers(BuildContext context) => MarkersTool(names: _names(context));

Widget _bank(BuildContext context) => BankTool(names: _names(context));

Widget _auction(BuildContext context) => AuctionTool(names: _names(context));

Widget _tournament(BuildContext context) =>
    TournamentTool(names: _names(context));

Widget _balance(BuildContext context) => BalanceTool(names: _names(context));

Widget _league(BuildContext context) =>
    LeagueTool(names: _names(context));
Widget _solo(BuildContext context) =>
    const SoloTool();
Widget _units(BuildContext context) =>
    const UnitsTool();

Widget _turns(BuildContext context) => TurnsTool(names: _names(context));

Widget _firstPlayer(BuildContext context) =>
    FirstPlayerTool(names: _names(context));

Widget _impostor(BuildContext context) => const ImpostorTool();

Widget _oracle(BuildContext context) => const OracleTool();

Widget _challenges(BuildContext context) => const ChallengesTool();

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
  const _ToolsPage({this.initialTool, this.initialCategory});
  final String? initialTool, initialCategory;

  @override
  Widget build(BuildContext context) => ToolsScreen(
    key: ValueKey('$initialTool$initialCategory'),
    initialTool: initialTool,
    initialCategory: initialCategory,
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

const Map<String, WidgetBuilder> embeddedToolBuilders = {
          'scores': _scores,
          'timer': _timer,
          'stopwatch': _stopwatch,
          'chess-clock': _chessClock,
          'deck': _deck,
          'rules': rulesWithStorage,
          'worldmap': worldWithStorage,
          'gmtables': tablesWithStorage,
          'scenes': scenesWithStorage,
          'bestiary': bestiaryWithStorage,
          'combat': combatWithStorage,
          'vote': _vote,
          'countdown': countdownWithFeedback,
          'phases': phasesWithFeedback,
          'metronome': metronomeWithFeedback,
          'life': _life,
          'tally': _tally,
          'ranking': _ranking,
          'buzzer': _buzzer,
          'clocks': _clocks,
          'sport': _sport,
          'markers': _markers,
          'bank': _bank,
          'auction': _auction,
          'tournament': _tournament,
          'balance': _balance,
          'league': _league,
          'solo': _solo,
          'units': _units,
          'stats': _stats,
          'sheet': _sheet,
          'turns': _turns,
          'first-player': _firstPlayer,
          'turn-timer': turnTimerWithFeedback,
          'impostor': _impostor,
          'oracle': _oracle,
          'challenges': _challenges,
          'journal': journalWithStorage,
          'ambience': ambienceWithSound,
          'dice-tray': diceTrayWithSensors,
          'coin': coinWithSensors,
          'hourglass': hourglassWithSensors,
          'map': mapWithStorage,
          'heroes': _heroes,
          'counter-life': _counterLife,
          'counter-points': _counterPoints,
          'counter-chips': _counterChips,
          'counter-pot': _counterPot,
};

Widget? _brickWidget(BuildContext context, Brick brick) {
  if (brick.type == 'counter') {
    return CounterTool(
      settings: CounterSettings.fromJson(brick.settings),
      name: context.toolTitle(brick.toolId),
    );
  }
  return embeddedToolBuilders[brick.type]?.call(context);
}

final router = GoRouter(
  routes: [
    ...notebookRoutes,
    _page('/chronicles', (state) => const _ChroniclesRoute()),
    _page('/build', (state) => const CompanionBuilder()),
    _page(
      '/build/:id',
      (state) => CompanionBuilder(id: state.pathParameters['id']),
    ),
    _page(
      '/play/:id',
      (state) => CompanionSession(
        id: state.pathParameters['id']!,
        builder: _brickWidget,
      ),
    ),
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
        embeddedTools: embeddedToolBuilders,
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
    _page(
      '/library/scan',
      (state) => BlocProvider(
        create: (_) => getIt<BarcodeScanCubit>(),
        child: ScanBarcodeScreen(scanner: getIt<BarcodeScannerBuilder>()),
      ),
    ),
    _page('/library/tonight', (state) => const TonightScreen()),
    _page(
      '/library/edit/:id',
      (state) => ShelfGameForm(
        id: state.pathParameters['id']!,
        draft: state.extra is ShelfGame ? state.extra as ShelfGame : null,
      ),
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
        (state) => _ToolsPage(
          initialTool: state.uri.queryParameters['tool'],
          initialCategory: state.uri.queryParameters['category'],
        ),
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
            AppShell(
              path: state.uri.path,
              shelf: state.uri.queryParameters['category'],
              child: screen(state),
            ),
      ),
  ],
);
