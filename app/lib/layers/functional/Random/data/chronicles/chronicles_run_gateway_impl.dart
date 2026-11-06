import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_gateways.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class ChroniclesRunSlot {
  const ChroniclesRunSlot([this.run]);
  final Map<String, dynamic>? run;
}

class ChroniclesRunGatewayImpl extends StoredDocument<ChroniclesRunSlot>
    implements ChroniclesRunGateway {
  ChroniclesRunGatewayImpl(super.store)
    : super(
        id: 'chronicles_run',
        empty: const ChroniclesRunSlot(),
        fromJson: (j) => ChroniclesRunSlot(
          j['run'] == null ? null : Map<String, dynamic>.from(j['run'] as Map),
        ),
        toJson: (slot) => {'run': slot.run},
      );

  @override
  Map<String, dynamic>? get stored => current.run;

  @override
  Future<void> saveRun(Map<String, Object?>? run) => save(
    ChroniclesRunSlot(run == null ? null : Map<String, dynamic>.from(run)),
  );

  @override
  Map<String, Object?> backup() => const {};
}
