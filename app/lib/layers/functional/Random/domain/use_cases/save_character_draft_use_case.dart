import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft_slot.dart';
import 'package:amiludo/layers/functional/Random/domain/gateways/character_draft_gateway.dart';

class SaveCharacterDraftUseCase {
  SaveCharacterDraftUseCase(this._drafts);

  final CharacterDraftGateway _drafts;

  Future<void> call(CharacterDraft draft) =>
      _drafts.save(CharacterDraftSlot(draft));
}
