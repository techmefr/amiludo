import 'package:amiludo/layers/functional/Random/domain/entities/character_draft_slot.dart';
import 'package:amiludo/layers/functional/Random/domain/gateways/character_draft_gateway.dart';

class ClearCharacterDraftUseCase {
  ClearCharacterDraftUseCase(this._drafts);

  final CharacterDraftGateway _drafts;

  Future<void> call() => _drafts.save(const CharacterDraftSlot());
}
