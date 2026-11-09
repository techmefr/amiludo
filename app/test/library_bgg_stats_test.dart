import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/imported_game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/library_stats.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/collection_import_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/import_collection_use_case.dart';
import 'package:amiludo/layers/technical/Barcode/bgg_client.dart';
import 'package:amiludo/layers/technical/Barcode/bgg_collection.dart';
import 'package:amiludo/layers/technical/Barcode/product_lookup.dart';

import 'fakes.dart';

const collectionXml = '''
<items totalitems="2">
  <item objecttype="thing" objectid="13" subtype="boardgame">
    <name sortindex="1">Rock &amp; Roll</name>
    <thumbnail>https://cf.geekdo-images.com/a.jpg</thumbnail>
    <stats minplayers="3" maxplayers="4" minplaytime="60" maxplaytime="120" playingtime="120" numowned="5"><rating value="N/A"/></stats>
    <status own="1"/>
  </item>
  <item objecttype="thing" objectid="14" subtype="boardgame">
    <name sortindex="1">Skull</name>
    <stats minplayers="3" maxplayers="6" playingtime="30"/>
  </item>
</items>''';

class FakeCollection implements CollectionImportGateway {
  FakeCollection(this.games, {this.fail = false});

  final List<ImportedGame> games;
  final bool fail;

  @override
  bool get available => true;

  @override
  Future<List<ImportedGame>> collection(String username) async {
    if (fail) throw const BarcodeLookupFailure();
    return games;
  }
}

void main() {
  test('a BGG collection answer is parsed with players, time and cover', () {
    final items = parseBggCollection(collectionXml);
    expect(items.map((i) => i.name), ['Rock & Roll', 'Skull']);
    expect(items.first.imageUrl, 'https://cf.geekdo-images.com/a.jpg');
    expect(
      [items.first.minPlayers, items.first.maxPlayers, items.first.minutes],
      [3, 4, 120],
    );
    expect(items.last.imageUrl, '');
  });

  test('the collection call waits through the queued answer', () async {
    var calls = 0;
    final client = BggClient(
      token: 'abc',
      retryDelay: Duration.zero,
      client: MockClient((_) async {
        calls++;
        return calls < 3
            ? http.Response('', 202)
            : http.Response(collectionXml, 200);
      }),
    );
    expect((await client.collection('gaetan')).length, 2);
    expect(calls, 3);
  });

  test('a refused or tokenless collection call is explicit', () async {
    expect(await BggClient().collection('gaetan'), isEmpty);
    final refused = BggClient(
      token: 'abc',
      client: MockClient((_) async => http.Response('', 401)),
    );
    await expectLater(
      refused.collection('gaetan'),
      throwsA(isA<ProductLookupException>()),
    );
  });

  test('import adds only games not already on the shelf', () async {
    final shelf = MemoryShelf(
      const Shelf(games: [ShelfGame(id: 'k', name: 'skull')]),
    );
    final import = ImportCollectionUseCase(
      shelf,
      FakeCollection(const [
        ImportedGame(name: 'Skull'),
        ImportedGame(name: 'Catan', minPlayers: 3, maxPlayers: 4, minutes: 90),
        ImportedGame(name: 'Odd', imageUrl: 'http://insecure/x.jpg'),
      ]),
    );
    expect(await import('gaetan'), 2);
    expect(shelf.current.games.map((g) => g.name), ['Catan', 'Odd', 'skull']);
    expect(shelf.current.games.first.minutes, 90);
    expect(shelf.current.games[1].imageUrl, '');
    expect(shelf.current.games[1].maxPlayers, 2);
    expect(await import('gaetan'), 0);
    expect(await import('  '), 0);
  });

  test('a failing import leaves the shelf untouched', () async {
    final shelf = MemoryShelf();
    final import = ImportCollectionUseCase(
      shelf,
      FakeCollection(const [], fail: true),
    );
    await expectLater(
      import('gaetan'),
      throwsA(isA<BarcodeLookupFailure>()),
    );
    expect(shelf.current.games, isEmpty);
  });

  test('stats split played and never played games', () {
    const games = [
      ShelfGame(id: 'a', name: 'Catan'),
      ShelfGame(id: 'b', name: 'Skull', templateIds: ['pack-skull']),
      ShelfGame(id: 'c', name: 'Dixit'),
    ];
    final stats = LibraryStats.of(games, [
      (title: 'catan', packId: null),
      (title: 'Soirée', packId: 'pack-skull'),
    ]);
    expect(stats.played, {'a', 'b'});
    expect(stats.neverPlayed, {'c'});
    expect(LibraryStats.of(games, const []).neverPlayed.length, 3);
  });
}
