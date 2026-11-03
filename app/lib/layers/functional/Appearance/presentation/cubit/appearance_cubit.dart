import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Appearance/domain/use_cases/change_appearance_use_case.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/remove_style_profile_use_case.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/save_style_profile_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';

class AppearanceCubit extends Cubit<Workspace> {
  AppearanceCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._changeAppearance,
    this._saveStyleProfile,
    this._removeStyleProfile,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final ChangeAppearanceUseCase _changeAppearance;
  final SaveStyleProfileUseCase _saveStyleProfile;
  final RemoveStyleProfileUseCase _removeStyleProfile;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> change(Appearance appearance) => _changeAppearance(appearance);

  Future<void> saveProfile(String name) => _saveStyleProfile(name);

  Future<void> removeProfile(int index) => _removeStyleProfile(index);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
