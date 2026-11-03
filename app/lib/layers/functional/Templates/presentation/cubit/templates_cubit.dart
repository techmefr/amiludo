import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/add_template_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/remove_template_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class TemplatesCubit extends Cubit<Workspace> {
  TemplatesCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._addTemplate,
    this._removeTemplate,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final AddTemplateUseCase _addTemplate;
  final RemoveTemplateUseCase _removeTemplate;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> addTemplate(GameTemplate template) => _addTemplate(template);

  Future<void> removeTemplate(String id) => _removeTemplate(id);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
