import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Storage/store_database.dart';

void main() {
  test('blobs are stored, replaced, read and deleted', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    await db.writeBlob('a', Uint8List.fromList([1, 2]), 'audio/mpeg');
    await db.writeBlob('a', Uint8List.fromList([9]), 'audio/wav');
    final blob = await db.readBlob('a');
    expect(blob!.bytes, [9]);
    expect(blob.mimeType, 'audio/wav');
    await db.deleteBlob('a');
    expect(await db.readBlob('a'), isNull);
    await db.close();
  });

  test(
    'blobs do not disturb stored documents and clearAll wipes both',
    () async {
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      await db.writeDocument('doc', 'keep');
      await db.writeBlob('a', Uint8List.fromList([1]), 'audio/mpeg');
      expect(await db.readDocument('doc'), 'keep');
      await db.clearAll();
      expect(await db.readDocument('doc'), isNull);
      expect(await db.readBlob('a'), isNull);
      await db.close();
    },
  );

  test('schema is at version 2', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    expect(db.schemaVersion, 2);
    await db.close();
  });
}
