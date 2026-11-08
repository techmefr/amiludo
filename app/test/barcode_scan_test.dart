import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/functional/Library/data/gateways/barcode_cache_gateway_impl.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_cache_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/resolve_barcode_use_case.dart';
import 'package:amiludo/layers/technical/Barcode/barcode_scanner_view.dart';
import 'package:amiludo/layers/technical/Barcode/bgg_client.dart';
import 'package:amiludo/layers/technical/Barcode/product_lookup.dart';
import 'package:amiludo/layers/technical/Barcode/upc_item_db_client.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

import 'fakes.dart';

const code = '3770000000001';

class FakeLookup implements BarcodeLookupGateway {
  FakeLookup({this.product, this.fail = false});

  BarcodeProduct? product;
  bool fail;
  int calls = 0;

  @override
  Future<BarcodeProduct?> lookup(String code) async {
    calls++;
    if (fail) throw const BarcodeLookupFailure();
    return product;
  }
}

class MemoryCache implements BarcodeCacheGateway {
  final entries = <String, BarcodeProduct>{};

  @override
  Future<BarcodeProduct?> read(String code) async => entries[code];

  @override
  Future<void> write(String code, BarcodeProduct product) async =>
      entries[code] = product;
}

UpcItemDbClient upc(int status, Object body) => UpcItemDbClient(
  client: MockClient((_) async => http.Response(jsonEncode(body), status)),
  baseUrl: 'https://example.test',
);

void main() {
  _clientTests();
  _useCaseTests();
  _screenTests();
}

void _clientTests() {
  test('UPCitemdb answer gives a title and an https cover', () async {
    final hit = await upc(200, {
      'items': [
        {
          'title': ' Catan ',
          'images': ['http://insecure/a.jpg', 'https://secure/b.jpg'],
        },
      ],
    }).lookup(code);
    expect(hit?.title, 'Catan');
    expect(hit?.imageUrl, 'https://secure/b.jpg');
  });

  test('UPCitemdb knows no item, rate limit and broken network', () async {
    expect(await upc(200, {'items': []}).lookup(code), isNull);
    expect(await upc(404, {}).lookup(code), isNull);
    await expectLater(
      upc(429, {'code': 'EXCEED_LIMIT'}).lookup(code),
      throwsA(isA<ProductLookupException>()),
    );
    final broken = UpcItemDbClient(
      client: MockClient((_) async => throw http.ClientException('down')),
    );
    await expectLater(
      broken.lookup(code),
      throwsA(isA<ProductLookupException>()),
    );
  });

  test('BGG search needs a token and decodes names', () async {
    expect(BggClient().configured, isFalse);
    expect(await BggClient().search('Catan'), isEmpty);
    String? auth;
    final client = BggClient(
      token: 'abc',
      client: MockClient((request) async {
        auth = request.headers['Authorization'];
        return http.Response(
          '<items><item id="1"><name type="primary" value="Rock &amp; Roll"/></item></items>',
          200,
        );
      }),
    );
    expect((await client.search('rock')).single.title, 'Rock & Roll');
    expect(auth, 'Bearer abc');
  });
}

void _useCaseTests() {
  const catan = ShelfGame(id: 'c', name: 'Catan', barcode: code);

  ResolveBarcodeUseCase build(
    FakeLookup lookup,
    MemoryCache cache, [
    Shelf shelf = const Shelf(),
  ]) => ResolveBarcodeUseCase(MemoryShelf(shelf), cache, lookup);

  test('a shelved code is found locally without any call', () async {
    final lookup = FakeLookup();
    final match = await build(
      lookup,
      MemoryCache(),
      const Shelf(games: [catan]),
    )('377-000 000 0001');
    expect(match.owned?.id, 'c');
    expect(lookup.calls, 0);
  });

  test('a remote answer is cached and not asked twice', () async {
    final lookup = FakeLookup(product: const BarcodeProduct(title: 'Catan'));
    final cache = MemoryCache();
    final resolve = build(lookup, cache);
    expect((await resolve(code)).product?.title, 'Catan');
    expect((await resolve(code)).product?.title, 'Catan');
    expect(lookup.calls, 1);
    expect(cache.entries.keys, [code]);
  });

  test('unknown and unreachable codes are not cached', () async {
    final cache = MemoryCache();
    final unknown = await build(FakeLookup(), cache)(code);
    expect(unknown.product, isNull);
    expect(unknown.unreachable, isFalse);
    final down = await build(FakeLookup(fail: true), cache)(code);
    expect(down.unreachable, isTrue);
    expect(cache.entries, isEmpty);
  });

  test('the cache survives a restart of the document store', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    await BarcodeCacheGatewayImpl(DocumentStore(db)).write(
      code,
      const BarcodeProduct(title: 'Catan', imageUrl: 'https://x/y.jpg'),
    );
    final again = await BarcodeCacheGatewayImpl(DocumentStore(db)).read(code);
    expect(again?.title, 'Catan');
    expect(again?.imageUrl, 'https://x/y.jpg');
    await db.close();
  });
}

Future<FakeLookup> _open(WidgetTester tester, FakeLookup lookup) async {
  tester.view.physicalSize = const Size(1440, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  getIt.unregister<BarcodeLookupGateway>();
  getIt.registerSingleton<BarcodeLookupGateway>(lookup);
  getIt.unregister<BarcodeScannerBuilder>();
  getIt.registerSingleton<BarcodeScannerBuilder>(
    (onCode, unavailable) => TextButton(
      onPressed: () => onCode(code),
      child: const Text('fake-scan'),
    ),
  );
  await tester.pumpWidget(const AmiludoApp());
  router.go('/library/scan');
  await tester.pumpAndSettle();
  return lookup;
}

void _screenTests() {
  testWidgets('scanning an unknown code opens a form that keeps the code', (
    tester,
  ) async {
    final lookup = await _open(tester, FakeLookup());
    await tester.tap(find.text('fake-scan'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, code);
    await tester.enterText(fields.first, 'Catan');
    await tester.ensureVisible(find.text('Ranger sur l’étagère'));
    await tester.tap(find.text('Ranger sur l’étagère'));
    await tester.pumpAndSettle();
    expect(getIt<LibraryGateway>().current.games.single.barcode, code);
    router.go('/library/scan');
    await tester.pumpAndSettle();
    await tester.tap(find.text('fake-scan'));
    await tester.pumpAndSettle();
    expect(find.text('Déjà sur votre étagère'), findsOneWidget);
    expect(lookup.calls, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a found product prefills the form, typing works too', (
    tester,
  ) async {
    await _open(
      tester,
      FakeLookup(product: const BarcodeProduct(title: 'Catan')),
    );
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.tap(find.text('Rechercher'));
    await tester.pump();
    expect(find.text('Saisissez 8 à 14 chiffres.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, code);
    await tester.tap(find.text('Rechercher'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Catan',
    );
    await tester.pumpWidget(const SizedBox());
  });
}
