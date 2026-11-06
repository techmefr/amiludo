import 'package:amiludo/layers/functional/Workspace/domain/gateways/data_wipe_gateway.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

class DataWipeGatewayImpl implements DataWipeGateway {
  DataWipeGatewayImpl(this._database);

  final StoreDatabase _database;

  @override
  Future<void> call() => _database.clearAll();
}
