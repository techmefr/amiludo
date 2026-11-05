import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/gateways/character_draft_gateway.dart';

class ReadCharacterDraftUseCase {
  ReadCharacterDraftUseCase(this._drafts);

  final CharacterDraftGateway _drafts;

  CharacterDraft? call(String packName) {
    final draft = _drafts.current.draft;
    return draft != null && draft.packName == packName ? draft : null;
  }
}
