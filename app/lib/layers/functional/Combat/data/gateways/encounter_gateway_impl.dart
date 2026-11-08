import 'package:amiludo/layers/functional/Combat/domain/entities/encounter.dart';
import 'package:amiludo/layers/functional/Combat/domain/gateways/encounter_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class EncounterGatewayImpl extends StoredDocument<Encounter>
    implements EncounterGateway {
  EncounterGatewayImpl(super.store)
    : super(
        id: 'combat',
        empty: const Encounter(),
        fromJson: _decode,
        toJson: (encounter) => {'combat': encounter.toJson()},
      );

  static Encounter _decode(Map<String, dynamic> json) {
    final stored = json['combat'];
    if (stored is! Map) return const Encounter();
    return Encounter.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
