import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/functional/Notebook/data/gateways/notebook_gateways_impl.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/domain/use_cases/notebook_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/atlas_map_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_card.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaigns_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_screen.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/notebook_images.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/functional/Notebook/domain/gateways/notebook_gateways.dart';

class _Bundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (!file.existsSync()) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

class _Images implements NotebookImageGateway {
  final stored = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String id) async => stored[id];

  @override
  Future<void> write(String id, List<int> bytes) async =>
      stored[id] = Uint8List.fromList(bytes);

  @override
  Future<void> delete(String id) async => stored.remove(id);
}

class _Harness {
  _Harness(this.db) {
    gateway = NotebookGatewayImpl(DocumentStore(db));
    final images = _Images();
    cubit = NotebookCubit(
      ReadNotebookUseCase(gateway),
      WatchNotebookUseCase(gateway),
      SaveCampaignUseCase(gateway, images),
      DeleteCampaignUseCase(gateway, images),
      ExportCampaignUseCase(gateway, images),
      ImportCampaignUseCase(gateway, images),
      clock: () => DateTime(2026, 11, 7, 14, 30),
    );
    imageTools = NotebookImages(
      importImage: ImportNotebookImageUseCase(images).call,
      readImage: ReadNotebookImageUseCase(images).call,
      pick: () async => null,
    );
  }

  final StoreDatabase db;
  late final NotebookGatewayImpl gateway;
  late final NotebookCubit cubit;
  late final NotebookImages imageTools;
  String? shared;

  Widget app(String initial) {
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/notebook',
          builder: (_, _) => CampaignsScreen(
            pickFile: () async => shared,
            shareFile: (text, name) async => shared = text,
          ),
        ),
        GoRoute(
          path: '/notebook/:id',
          builder: (_, s) => CampaignScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/notebook/:id/map/:place',
          builder: (_, s) => AtlasMapScreen(
            campaignId: s.pathParameters['id']!,
            placeId: s.pathParameters['place']!,
            readBoard: (_) => const MapBoard(),
            buildMap: (context, key, onChanged) => TextButton(
              onPressed: () => onChanged(
                MapBoard(
                  markers: [MapMarker(id: 'p1', x: 10, y: 10, label: 'Camp')],
                ),
              ),
              child: Text(key),
            ),
          ),
        ),
        GoRoute(
          path: '/notebook/:id/entry/:entry',
          builder: (_, s) => EntryScreen(
            campaignId: s.pathParameters['id']!,
            entryId: s.pathParameters['entry']!,
          ),
        ),
      ],
    );
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: imageTools)],
      child: BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(
          routerConfig: router,
          theme: deckTheme(const Appearance(), Brightness.light),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              DefaultAssetBundle(bundle: _Bundle(), child: child!),
        ),
      ),
    );
  }
}

Future<_Harness> _open(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return _Harness(db);
}

NotebookCampaign _seed() {
  final mira = NotebookEntry.create(EntryKind.npc, 'Mira');
  return NotebookCampaign.create('Tides', CampaignKind.solo)
      .withEntry(mira)
      .withLine(
        JournalLine.create(
          JournalKind.note,
          'Met Mira at the docks',
          DateTime(2026, 11, 7, 14, 30),
        ),
        DateTime(2026, 11, 7, 14, 30),
      );
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    group('notebook at $size', () {
      testWidgets('a campaign is created, favourited and exported', (
        tester,
      ) async {
        final h = await _open(tester, size);
        await tester.pumpWidget(h.app('/notebook'));
        await tester.pumpAndSettle();
        expect(find.text('No campaign yet'), findsOneWidget);
        await tester.tap(find.text('New campaign').first);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Tides');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        expect(find.text('Journal'), findsOneWidget);
        expect(h.gateway.current.campaigns.single.title, 'Tides');
        await tester.tap(find.byTooltip('Favorite'));
        await tester.pumpAndSettle();
        expect(h.gateway.current.campaigns.single.favorite, isTrue);
        await tester.tap(find.byType(BackButtonIcon));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PopupMenuButton<CampaignAction>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Export'));
        await tester.pumpAndSettle();
        expect(h.shared, contains('amiludo-campaign'));
        await tester.tap(find.byTooltip('Import a campaign'));
        await tester.pumpAndSettle();
        expect(h.gateway.current.campaigns, hasLength(2));
      });

      testWidgets('a quick entry lands in the active session', (tester) async {
        final h = await _open(tester, size);
        final campaign = _seed();
        await h.gateway.save(h.gateway.current.put(campaign));
        await tester.pumpWidget(h.app('/notebook/${campaign.id}'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, 'Found a key');
        await tester.tap(find.byTooltip('Add'));
        await tester.pumpAndSettle();
        final lines = h.gateway.current.campaigns.single.sessions.single.lines;
        expect(lines.map((l) => l.text), [
          'Met Mira at the docks',
          'Found a key',
        ]);
        expect(find.text('Found a key'), findsOneWidget);
      });

      testWidgets('a name in the journal is a tappable link', (tester) async {
        final h = await _open(tester, size);
        final campaign = _seed();
        await h.gateway.save(h.gateway.current.put(campaign));
        await tester.pumpWidget(h.app('/notebook/${campaign.id}'));
        await tester.pumpAndSettle();
        await tester.tapOnText(find.textRange.ofSubstring('Mira'));
        await tester.pumpAndSettle();
        expect(find.text('Character'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Mira'), findsOneWidget);
        expect(find.text('Mentioned in'), findsOneWidget);
      });

      testWidgets('an entry is created and searched', (tester) async {
        final h = await _open(tester, size);
        final campaign = _seed();
        await h.gateway.save(h.gateway.current.put(campaign));
        await tester.pumpWidget(h.app('/notebook/${campaign.id}'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Entries'));
        await tester.tap(find.text('Entries'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('New entry'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, 'Black Isle');
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Place'),
          ),
        );
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        final saved = h.gateway.current.campaigns.single.entries.last;
        expect(saved.name, 'Black Isle');
        expect(saved.kind, EntryKind.place);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'docks');
        await tester.pumpAndSettle();
        expect(find.textContaining('Met Mira'), findsOneWidget);
      });

      testWidgets('an oracle answer is added to the journal', (tester) async {
        final h = await _open(tester, size);
        final campaign = _seed();
        await h.gateway.save(h.gateway.current.put(campaign));
        await tester.pumpWidget(h.app('/notebook/${campaign.id}'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Oracle').first);
        await tester.tap(find.text('Oracle').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ask the oracle'));
        await tester.pumpAndSettle();
        expect(find.text('Yes or no question'), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Add to journal'));
        await tester.tap(find.byTooltip('Add to journal'));
        await tester.pumpAndSettle();
        final lines = h.gateway.current.campaigns.single.sessions.single.lines;
        expect(lines.last.kind, JournalKind.oracle);
        expect(lines.last.text, startsWith('Even odds'));
      });

      testWidgets('places nest in the atlas and pins link to entries', (
        tester,
      ) async {
        final h = await _open(tester, size);
        final isle = NotebookEntry.create(EntryKind.place, 'Black Isle');
        final campaign = _seed().withEntry(isle);
        await h.gateway.save(h.gateway.current.put(campaign));
        await tester.pumpWidget(h.app('/notebook/${campaign.id}'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Atlas'));
        await tester.tap(find.text('Atlas'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('New place').last);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Port');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        final port = h.gateway.current.campaigns.single.entries.last;
        expect(port.name, 'Port');
        expect(port.parentId, isle.id);
        await tester.tap(find.byTooltip('Open the map').first);
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('nb:'));
        await tester.pumpAndSettle();
        expect(find.text('Camp'), findsOneWidget);
        await tester.tap(find.byTooltip('Link to'));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Mira').last);
        await tester.pumpAndSettle();
        final links = h.gateway.current.campaigns.single.pinLinks;
        expect(links.values.single, isNotEmpty);
        expect(find.text('Mira'), findsOneWidget);
      });

      testWidgets('search spans every campaign', (tester) async {
        final h = await _open(tester, size);
        final first = _seed();
        final second = NotebookCampaign.create(
          'Dunes',
          CampaignKind.gm,
        ).withEntry(NotebookEntry.create(EntryKind.npc, 'Miraculous Oasis'));
        await h.gateway.save(h.gateway.current.put(first).put(second));
        await tester.pumpWidget(h.app('/notebook'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'mira');
        await tester.pumpAndSettle();
        expect(find.text('Tides'), findsWidgets);
        expect(find.textContaining('Dunes'), findsOneWidget);
        await tester.tap(find.text('Miraculous Oasis'));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(TextField, 'Miraculous Oasis'),
          findsOneWidget,
        );
      });
    });
  }
}
