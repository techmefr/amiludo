import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class NextRoundUseCase {
  NextRoundUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call() {
    final data = _workspace.current;
    final current = data.current!;
    return _workspace.save(
      data.withGame(current.copyWith(round: current.round + 1)),
    );
  }
}
