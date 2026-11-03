import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/invite_user_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/list_users_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/remove_user_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/set_user_admin_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/set_user_blocked_use_case.dart';

enum AdminStatus { loading, ready, failed }

enum AdminNotice { invited, updated, removed }

class AdminState {
  const AdminState({
    this.status = AdminStatus.loading,
    this.users = const [],
    this.busy = false,
    this.error,
    this.notice,
  });

  final AdminStatus status;
  final List<ManagedUser> users;
  final bool busy;
  final AdminError? error;
  final AdminNotice? notice;

  AdminState copyWith({
    AdminStatus? status,
    List<ManagedUser>? users,
    bool? busy,
    AdminError? error,
    AdminNotice? notice,
  }) => AdminState(
    status: status ?? this.status,
    users: users ?? this.users,
    busy: busy ?? this.busy,
    error: error,
    notice: notice,
  );
}

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(
    this._list,
    this._invite,
    this._setAdmin,
    this._setBlocked,
    this._remove,
  ) : super(const AdminState());

  final ListUsersUseCase _list;
  final InviteUserUseCase _invite;
  final SetUserAdminUseCase _setAdmin;
  final SetUserBlockedUseCase _setBlocked;
  final RemoveUserUseCase _remove;

  AdminError _errorOf(Object error) => switch (error) {
    final AdminError known => known,
    _ => AdminError.unreachable,
  };

  Future<void> load() async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      emit(state.copyWith(status: AdminStatus.ready, users: await _list()));
    } catch (error) {
      emit(state.copyWith(status: AdminStatus.failed, error: _errorOf(error)));
    }
  }

  Future<bool> _act(Future<void> Function() action, AdminNotice notice) async {
    emit(state.copyWith(busy: true));
    try {
      await action();
      final users = await _list();
      emit(state.copyWith(busy: false, users: users, notice: notice));
      return true;
    } catch (error) {
      emit(state.copyWith(busy: false, error: _errorOf(error)));
      return false;
    }
  }

  Future<bool> invite(String email, String name) =>
      _act(() => _invite(email: email, name: name), AdminNotice.invited);

  Future<bool> toggleAdmin(ManagedUser user) =>
      _act(() => _setAdmin(user), AdminNotice.updated);

  Future<bool> toggleBlocked(ManagedUser user) =>
      _act(() => _setBlocked(user), AdminNotice.updated);

  Future<bool> remove(ManagedUser user) =>
      _act(() => _remove(user), AdminNotice.removed);
}
