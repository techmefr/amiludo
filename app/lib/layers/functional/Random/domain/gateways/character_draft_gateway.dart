import 'package:amiludo/layers/functional/Random/domain/entities/character_draft_slot.dart';

abstract class CharacterDraftGateway {
  CharacterDraftSlot get current;
  Future<void> save(CharacterDraftSlot slot);
}
