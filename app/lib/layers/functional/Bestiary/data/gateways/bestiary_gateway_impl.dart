import 'package:amiludo/layers/functional/Bestiary/domain/entities/bestiary.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/gateways/bestiary_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class BestiaryGatewayImpl extends StoredDocument<Bestiary>
    implements BestiaryGateway {
  BestiaryGatewayImpl(super.store)
    : super(
        id: 'bestiary',
        empty: const Bestiary(),
        fromJson: _decode,
        toJson: (bestiary) => {'bestiary': bestiary.toJson()},
      );

  static Bestiary _decode(Map<String, dynamic> json) {
    final stored = json['bestiary'];
    if (stored is! Map) return const Bestiary();
    return Bestiary.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
