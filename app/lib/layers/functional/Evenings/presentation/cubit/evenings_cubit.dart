import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/domain/use_cases/watch_account_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/answer_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/fetch_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/publish_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/remove_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/save_evening_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';

class EveningsCubit extends Cubit<Workspace> {
  EveningsCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._account,
    this._save,
    this._remove,
    this._publish,
    this._answer,
    this._fetch,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final WatchAccountUseCase _account;
  final SaveEveningUseCase _save;
  final RemoveEveningUseCase _remove;
  final PublishEveningUseCase _publish;
  final AnswerEveningUseCase _answer;
  final FetchEveningUseCase _fetch;
  late final StreamSubscription<Workspace> _subscription;

  bool get online => _account.available;

  bool get signedIn => _account.current != null;

  String? get myId => _account.current?.id;

  Evening? evening(String id) =>
      state.evenings.where((e) => e.id == id).firstOrNull;

  Evening draft() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return Evening(
      id: 'evening-${DateTime.now().microsecondsSinceEpoch}',
      code: newRoomCode(8),
      title: '',
      startsAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20),
      hostName: state.nickname,
      seats: 6,
    );
  }

  Future<void> save(Evening evening) => _save(evening);

  Future<void> remove(String id) => _remove(id);

  Future<Evening> publish(Evening evening) => _publish(evening);

  Future<Evening> answer(
    String id,
    RsvpAnswer answer, {
    String? guestId,
    String? guestName,
  }) => _answer(id, answer, guestId: guestId, guestName: guestName);

  Future<Evening?> fetch(String code) => _fetch(code);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
