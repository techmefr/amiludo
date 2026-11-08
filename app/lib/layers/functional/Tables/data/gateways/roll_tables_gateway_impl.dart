import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';
import 'package:amiludo/layers/functional/Tables/domain/gateways/roll_tables_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class RollTablesGatewayImpl extends StoredDocument<RollTables>
    implements RollTablesGateway {
  RollTablesGatewayImpl(super.store)
    : super(
        id: 'rolltables',
        empty: const RollTables(),
        fromJson: _decode,
        toJson: (tables) => {'rollTables': tables.toJson()},
      );

  static RollTables _decode(Map<String, dynamic> json) {
    final stored = json['rollTables'];
    if (stored is! Map) return const RollTables();
    return RollTables.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
