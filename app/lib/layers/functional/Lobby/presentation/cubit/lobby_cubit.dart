import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/decide_seat_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/host_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/join_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/leave_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/start_lobby_game_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/toggle_lobby_open_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/watch_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';

enum LobbyError { invalid, notFound, unreachable, failed }

class LobbyState {
  const LobbyState({
    this.session,
    this.busy = false,
    this.error,
    required this.lanSupported,
    required this.remoteSupported,
  });

  final LobbySession? session;
  final bool busy, lanSupported, remoteSupported;
  final LobbyError? error;

  LobbyState copyWith({
    LobbySession? session,
    bool clearSession = false,
    bool? busy,
    LobbyError? error,
  }) => LobbyState(
    session: clearSession ? null : session ?? this.session,
    busy: busy ?? this.busy,
    error: error,
    lanSupported: lanSupported,
    remoteSupported: remoteSupported,
  );
}

class LobbyCubit extends Cubit<LobbyState> {
  LobbyCubit(
    this._readWorkspace,
    WatchLobbyUseCase watch,
    this._host,
    this._join,
    this._decide,
    this._toggleOpen,
    this._start,
    this._leave,
  ) : super(
        LobbyState(
          session: watch.current,
          lanSupported: watch.lanSupported,
          remoteSupported: watch.remoteSupported,
        ),
      ) {
    _subscription = watch().listen(
      (session) =>
          emit(state.copyWith(session: session, clearSession: session == null)),
    );
  }

  final ReadWorkspaceUseCase _readWorkspace;
  final HostLobbyUseCase _host;
  final JoinLobbyUseCase _join;
  final DecideSeatUseCase _decide;
  final ToggleLobbyOpenUseCase _toggleOpen;
  final StartLobbyGameUseCase _start;
  final LeaveLobbyUseCase _leave;
  late final StreamSubscription<LobbySession?> _subscription;

  Future<void> _run(Future<LobbySession> Function() action) async {
    emit(state.copyWith(busy: true));
    try {
      emit(state.copyWith(session: await action(), busy: false));
    } on FormatException {
      emit(state.copyWith(busy: false, error: LobbyError.invalid));
    } on LobbyNotFound {
      emit(state.copyWith(busy: false, error: LobbyError.notFound));
    } on LobbyUnreachable {
      emit(state.copyWith(busy: false, error: LobbyError.unreachable));
    } catch (_) {
      emit(state.copyWith(busy: false, error: LobbyError.failed));
    }
  }

  Future<void> host({
    required String title,
    required String name,
    required int seats,
    required bool lan,
    required bool remote,
  }) => _run(
    () =>
        _host(title: title, name: name, seats: seats, lan: lan, remote: remote),
  );

  Future<void> join(String input, {required String name}) =>
      _run(() => _join(input, name: name));

  void decide(String seatId, {required bool accept}) =>
      _decide(seatId, accept: accept);

  String get nickname => _readWorkspace().nickname;

  void toggleOpen() => _toggleOpen();

  List<String> start() => _start();

  Future<void> leave() => _leave();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
