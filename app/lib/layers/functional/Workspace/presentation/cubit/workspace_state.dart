import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';

enum WorkspaceStatus { loading, ready, failure }

class WorkspaceState {
  const WorkspaceState({
    this.status = WorkspaceStatus.loading,
    this.workspace = const Workspace(),
    this.saveFailed = false,
  });

  final WorkspaceStatus status;
  final Workspace workspace;
  final bool saveFailed;

  WorkspaceState copyWith({
    WorkspaceStatus? status,
    Workspace? workspace,
    bool? saveFailed,
  }) => WorkspaceState(
    status: status ?? this.status,
    workspace: workspace ?? this.workspace,
    saveFailed: saveFailed ?? this.saveFailed,
  );
}
