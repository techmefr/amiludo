import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Sharing/domain/entities/session_bundle.dart';
import 'package:amiludo/layers/functional/Sharing/domain/use_cases/build_session_bundle_use_case.dart';
import 'package:amiludo/layers/functional/Sharing/domain/use_cases/import_session_bundle_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class SharingCubit extends Cubit<Workspace> {
  SharingCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._buildBundle,
    this._importBundle,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final BuildSessionBundleUseCase _buildBundle;
  final ImportSessionBundleUseCase _importBundle;
  late final StreamSubscription<Workspace> _subscription;

  SessionBundle bundle({
    List<String> shelfGameIds = const [],
    List<String> templateIds = const [],
  }) => _buildBundle(shelfGameIds: shelfGameIds, templateIds: templateIds);

  Future<SessionImport> receive(SessionBundle bundle) => _importBundle(bundle);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
