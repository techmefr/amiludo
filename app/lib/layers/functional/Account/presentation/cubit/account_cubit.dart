import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/reset_password_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/save_nickname_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_in_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_out_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_up_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/watch_account_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

enum AccountNotice { saved, checkMail, signedIn, signedOut, resetSent }

class AccountState {
  const AccountState({
    required this.available,
    required this.nickname,
    this.account,
    this.busy = false,
    this.error,
    this.notice,
  });

  final bool available, busy;
  final String nickname;
  final Account? account;
  final AccountError? error;
  final AccountNotice? notice;

  AccountState copyWith({
    String? nickname,
    Account? account,
    bool signedOut = false,
    bool? busy,
    AccountError? error,
    AccountNotice? notice,
  }) => AccountState(
    available: available,
    nickname: nickname ?? this.nickname,
    account: signedOut ? null : account ?? this.account,
    busy: busy ?? this.busy,
    error: error,
    notice: notice,
  );
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    WatchAccountUseCase watchAccount,
    this._signUp,
    this._signIn,
    this._signOut,
    this._resetPassword,
    this._saveNickname,
  ) : super(
        AccountState(
          available: watchAccount.available,
          nickname: readWorkspace().nickname,
          account: watchAccount.current,
        ),
      ) {
    _subscriptions = [
      watchWorkspace().listen(
        (data) => emit(state.copyWith(nickname: data.nickname)),
      ),
      watchAccount().listen(
        (account) =>
            emit(state.copyWith(account: account, signedOut: account == null)),
      ),
    ];
  }

  final SignUpUseCase _signUp;
  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;
  final ResetPasswordUseCase _resetPassword;
  final SaveNicknameUseCase _saveNickname;
  late final List<StreamSubscription<Object?>> _subscriptions;

  Future<void> _run(Future<AccountNotice> Function() action) async {
    emit(state.copyWith(busy: true));
    try {
      final notice = await action();
      emit(state.copyWith(busy: false, notice: notice));
    } on AccountError catch (error) {
      emit(state.copyWith(busy: false, error: error));
    } on AccountFailure {
      emit(state.copyWith(busy: false, error: AccountError.rejected));
    } on AccountUnavailable {
      emit(state.copyWith(busy: false, error: AccountError.unavailable));
    } catch (_) {
      emit(state.copyWith(busy: false, error: AccountError.unreachable));
    }
  }

  Future<void> saveNickname(String name) => _run(() async {
    await _saveNickname(name);
    return AccountNotice.saved;
  });

  Future<void> signUp(String email, String password, String name) =>
      _run(() async {
        final confirmed = await _signUp(
          email: email,
          password: password,
          name: name,
        );
        return confirmed ? AccountNotice.signedIn : AccountNotice.checkMail;
      });

  Future<void> signIn(String email, String password) => _run(() async {
    await _signIn(email: email, password: password);
    return AccountNotice.signedIn;
  });

  Future<void> resetPassword(String email) => _run(() async {
    await _resetPassword(email);
    return AccountNotice.resetSent;
  });

  Future<void> signOut() => _run(() async {
    await _signOut();
    return AccountNotice.signedOut;
  });

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
