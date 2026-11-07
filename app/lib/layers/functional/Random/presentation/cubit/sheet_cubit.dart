import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_generator.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_import.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_use_cases.dart';

class SheetState {
  const SheetState({
    this.generator,
    this.sheet,
    this.step = 1,
    this.reading = false,
    this.failed = false,
  });

  final SheetGenerator? generator;
  final CharacterSheet? sheet;
  final int step;
  final bool reading, failed;

  SheetState copyWith({CharacterSheet? sheet, int? step, bool? reading}) =>
      SheetState(
        generator: generator,
        sheet: sheet ?? this.sheet,
        step: step ?? this.step,
        reading: reading ?? this.reading,
      );
}

class SheetSeed {
  const SheetSeed({this.universe, this.kept, this.initial});
  final String? universe;
  final List<KeptCard>? kept;
  final CharacterSheet? initial;
}

class SheetCubit extends Cubit<SheetState> {
  SheetCubit(this._load, {this.random}) : super(const SheetState());

  final LoadSheetGeneratorUseCase _load;
  final RandomTools? random;

  SheetGenerator get _generator => state.generator!;
  CharacterSheet get _sheet => state.sheet!;

  Future<void> load({
    String? universe,
    List<KeptCard>? kept,
    CharacterSheet? initial,
  }) async {
    try {
      final generator = await _load(random: random);
      final sheet =
          initial ??
          (universe == null
              ? null
              : kept == null
              ? generator.blank(universe)
              : SheetImport.fromKept(generator, universe, kept));
      emit(
        SheetState(
          generator: generator,
          sheet: sheet,
          reading: kept != null || initial != null,
        ),
      );
    } on Object {
      emit(const SheetState(failed: true));
    }
  }

  void start(String universe) => emit(
    state.copyWith(sheet: _generator.blank(universe), step: 1, reading: false),
  );

  void generateAll() =>
      emit(state.copyWith(sheet: _generator.generateAll(_sheet), step: 1));

  void generateStep() =>
      emit(state.copyWith(sheet: _generator.generateStep(_sheet, state.step)));

  void reroll(String id) =>
      emit(state.copyWith(sheet: _generator.rerollField(_sheet, id)));

  void toggleLock(String id) =>
      emit(state.copyWith(sheet: _sheet.withLock(id, !_sheet.isLocked(id))));

  bool edit(String id, List<String> values) {
    try {
      emit(state.copyWith(sheet: _generator.edit(_sheet, id, values)));
      return true;
    } on FormatException {
      return false;
    }
  }

  void goTo(int step) =>
      emit(state.copyWith(step: step.clamp(1, SheetSpec.stepCount).toInt()));

  void setReading(bool reading) => emit(state.copyWith(reading: reading));
}
