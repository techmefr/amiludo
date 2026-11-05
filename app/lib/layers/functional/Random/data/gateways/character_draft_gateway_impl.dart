import 'package:amiludo/layers/functional/Random/domain/entities/character_draft_slot.dart';
import 'package:amiludo/layers/functional/Random/domain/gateways/character_draft_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class CharacterDraftGatewayImpl extends StoredDocument<CharacterDraftSlot>
    implements CharacterDraftGateway {
  CharacterDraftGatewayImpl(super.store)
    : super(
        id: 'character_draft',
        empty: const CharacterDraftSlot(),
        fromJson: CharacterDraftSlot.fromJson,
        toJson: (slot) => slot.toJson(),
      );

  @override
  Map<String, Object?> backup() => const {};
}
