import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/configure_clock_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/set_clock_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/toggle_clock_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class TimerCubit extends Cubit<Workspace> {
  TimerCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._setClock,
    this._toggleClock,
    this._configureClock,
    this.time,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final SetClockUseCase _setClock;
  final ToggleClockUseCase _toggleClock;
  final ConfigureClockUseCase _configureClock;
  final MonotonicTime time;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> setClock(GameClock clock) => _setClock(clock);

  Future<void> toggle() => _toggleClock();

  Future<void> configure(int seconds, int increment, bool bank) =>
      _configureClock(
        seconds,
        increment,
        bank,
        state.current?.players.map((p) => p.id) ?? const [],
      );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
