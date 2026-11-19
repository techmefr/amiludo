import 'dart:typed_data';

import 'package:drift/native.dart';

import 'package:amiludo/layers/functional/Sounds/data/gateways/sound_gateways_impl.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

class SoundRig {
  SoundRig() : database = StoreDatabase.forTesting(NativeDatabase.memory()) {
    library = SoundLibraryGatewayImpl(DocumentStore(database));
    blobs = SoundBlobGatewayImpl(database);
    sets = SoundSetUseCases(library, blobs);
  }

  final StoreDatabase database;
  late final SoundLibraryGatewayImpl library;
  late final SoundBlobGatewayImpl blobs;
  late final SoundSetUseCases sets;

  SoundSet get set => library.current.sets.first;

  Future<SoundSet> newSet({SoundOwnerKind kind = SoundOwnerKind.campaign}) =>
      sets.create(kind, 'campaign-1', 'Dragons');

  Future<SoundEntry> add(String name, SoundKind kind) => sets.importClip(
    set.id,
    name,
    Uint8List.fromList([1, 2, 3]),
    'audio/mpeg',
    kind,
  );
}
