import 'dart:typed_data';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_bundle.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';

class SaveDieUseCase {
  SaveDieUseCase(this._library, this._images);
  final DieLibraryGateway _library;
  final DieImageGateway _images;

  Future<void> call(
    DieDesign design, {
    Map<String, List<int>> images = const {},
  }) async {
    for (final e in images.entries) {
      await _images.write(e.key, e.value);
    }
    await _library.save(_library.current.upsert(design));
  }
}

class RemoveDieUseCase {
  RemoveDieUseCase(this._library, this._images);
  final DieLibraryGateway _library;
  final DieImageGateway _images;

  Future<void> call(String id) async {
    final design = _library.current.byId(id);
    if (design == null) return;
    await _library.save(_library.current.remove(id));
    final others = {for (final d in _library.current.designs) ...d.imageIds};
    for (final image in design.imageIds.difference(others)) {
      await _images.delete(image);
    }
  }
}

class DuplicateDieUseCase {
  DuplicateDieUseCase(this._library, this._images);
  final DieLibraryGateway _library;
  final DieImageGateway _images;

  Future<DieDesign?> call(String id, String name) async {
    final source = _library.current.byId(id);
    if (source == null) return null;
    final ids = {for (final i in source.imageIds) i: dieId()};
    for (final e in ids.entries) {
      final bytes = await _images.read(e.key);
      if (bytes != null) await _images.write(e.value, bytes);
    }
    final copy = source.copyWith(
      id: dieId(),
      name: name,
      faces: [
        for (final f in source.faces)
          f.kind == DieFaceKind.image ? f.copyWith(value: ids[f.value]) : f,
      ],
    );
    await _library.save(_library.current.upsert(copy));
    return copy;
  }
}

class ReadDieImageUseCase {
  ReadDieImageUseCase(this._images);
  final DieImageGateway _images;

  Future<Uint8List?> call(String id) => _images.read(id);
}

class ExportDiceUseCase {
  ExportDiceUseCase(this._library, this._images);
  final DieLibraryGateway _library;
  final DieImageGateway _images;

  Future<String> call(Iterable<String> ids) async {
    final designs = [
      for (final id in ids)
        if (_library.current.byId(id) != null) _library.current.byId(id)!,
    ];
    final images = <String, Uint8List>{};
    for (final d in designs) {
      for (final i in d.imageIds) {
        final bytes = await _images.read(i);
        if (bytes != null) images[i] = bytes;
      }
    }
    return DieBundle(designs, images).encode();
  }
}

class PreviewDiceImportUseCase {
  PreviewDiceImportUseCase(this._library);
  final DieLibraryGateway _library;

  ({DieBundle bundle, Set<String> clashes}) call(String text) {
    final bundle = DieBundle.decode(text);
    return (bundle: bundle, clashes: _library.current.clashes(bundle.designs));
  }
}

typedef DieIdMap = ({Map<String, String> designs, Map<String, String> images});

class ImportDiceUseCase {
  ImportDiceUseCase(this._library, this._images);
  final DieLibraryGateway _library;
  final DieImageGateway _images;

  Future<DieIdMap> call(DieBundle bundle, ClashPolicy policy) async {
    final fresh = bundle.remappedWithIds(dieId);
    final designs = <String, String>{};
    var next = _library.current;
    for (final d in fresh.bundle.designs) {
      var design = d;
      if (next.has(d.id) && policy == ClashPolicy.keepBoth) {
        design = d.copyWith(id: dieId());
        designs[d.id] = design.id;
      }
      next = next.upsert(design);
    }
    for (final e in fresh.bundle.images.entries) {
      await _images.write(e.key, e.value);
    }
    await _library.save(next);
    return (designs: designs, images: fresh.images);
  }
}
