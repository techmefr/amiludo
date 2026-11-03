import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';

abstract class WorkspaceGateway {
  Workspace get current;
  Stream<Workspace> get changes;
  Stream<bool> get saveFailures;
  Future<Workspace> load();
  Future<void> save(Workspace workspace);
  Future<void> retrySave();
}
