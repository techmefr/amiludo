import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_draw.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_use_cases.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

class ChroniclesState {
  const ChroniclesState({
    this.data,
    this.run,
    this.refusal,
    this.failed = false,
  });
  final ChroniclesData? data;
  final ChroniclesRun? run;
  final Refusal? refusal;
  final bool failed;
}

class ChroniclesCubit extends Cubit<ChroniclesState> {
  ChroniclesCubit(this._load, this._save, {RandomTools? random})
    : _random = random ?? RandomTools(),
      super(const ChroniclesState());

  final LoadChroniclesUseCase _load;
  final SaveChroniclesRunUseCase _save;
  final RandomTools _random;

  ChroniclesData get _data => state.data!;

  Future<void> load() async {
    try {
      final data = await _load.catalog();
      emit(ChroniclesState(data: data, run: _load.resume(data)));
    } on Object {
      emit(const ChroniclesState(failed: true));
    }
  }

  Future<void> _commit(ChroniclesRun? run, [Refusal? refusal]) async {
    await _save(run);
    emit(ChroniclesState(data: state.data, run: run, refusal: refusal));
  }

  Future<void> start(String universe) async {
    final run = ChroniclesRun(universe)..next(_data);
    await _commit(run);
  }

  Future<void> openBooster(String edition) {
    final run = state.run!
      ..openBooster(_data, ChroniclesDraw(_data, _random), edition);
    return _commit(run);
  }

  Future<void> keep() {
    final run = state.run!;
    return _commit(run, run.keep(_data));
  }

  Future<void> pass() {
    final run = state.run!..pass();
    return _commit(run);
  }

  Future<void> next() {
    final run = state.run!..next(_data);
    return _commit(run);
  }

  Future<void> letDestinyComplete() {
    final run = state.run!
      ..letDestinyComplete(_data, ChroniclesDraw(_data, _random));
    return _commit(run);
  }

  Future<void> restart() => _commit(null);
}
