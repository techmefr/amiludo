import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_bundle.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_use_cases.dart';

class DieStudioActions {
  const DieStudioActions({
    required this.save,
    required this.remove,
    required this.duplicate,
    required this.readImage,
    required this.export,
    required this.previewImport,
    required this.import,
  });
  final SaveDieUseCase save;
  final RemoveDieUseCase remove;
  final DuplicateDieUseCase duplicate;
  final ReadDieImageUseCase readImage;
  final ExportDiceUseCase export;
  final PreviewDiceImportUseCase previewImport;
  final ImportDiceUseCase import;
}

class DieStudioCubit extends Cubit<DieLibrary> {
  DieStudioCubit(this.actions, DieLibrary initial, Stream<DieLibrary> changes)
    : super(initial) {
    _sub = changes.listen(emit);
  }

  final DieStudioActions actions;
  late final StreamSubscription<DieLibrary> _sub;

  Future<void> save(DieDesign d, {Map<String, List<int>> images = const {}}) =>
      actions.save(d, images: images);

  Future<void> remove(String id) => actions.remove(id);

  Future<void> duplicate(String id, String name) => actions.duplicate(id, name);

  final Map<String, List<int>> staged = {};

  Future<Uint8List?> image(String id) async {
    final bytes = staged[id];
    return bytes == null ? actions.readImage(id) : Uint8List.fromList(bytes);
  }

  Future<String> export(Iterable<String> ids) => actions.export(ids);

  ({DieBundle bundle, Set<String> clashes}) previewImport(String text) =>
      actions.previewImport(text);

  Future<void> import(DieBundle bundle, ClashPolicy policy) =>
      actions.import(bundle, policy);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}

class DieStudio extends InheritedWidget {
  const DieStudio({super.key, required this.cubit, required super.child});
  final DieStudioCubit cubit;

  static DieStudioCubit? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DieStudio>()?.cubit;

  @override
  bool updateShouldNotify(DieStudio old) => old.cubit != cubit;
}
