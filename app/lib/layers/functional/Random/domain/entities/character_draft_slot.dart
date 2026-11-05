import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';

class CharacterDraftSlot {
  const CharacterDraftSlot([this.draft]);

  final CharacterDraft? draft;

  Map<String, Object?> toJson() => {'draft': draft?.toJson()};

  factory CharacterDraftSlot.fromJson(Map<String, dynamic> j) {
    final stored = j['draft'];
    if (stored == null) return const CharacterDraftSlot();
    return CharacterDraftSlot(
      CharacterDraft.fromJson(Map<String, dynamic>.from(stored as Map)),
    );
  }
}
