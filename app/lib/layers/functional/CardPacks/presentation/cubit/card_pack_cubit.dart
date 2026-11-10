import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/use_cases/card_pack_use_cases.dart';

class CardPackCubit extends Cubit<CardPackSession?> {
  CardPackCubit(ReadCardPackSessionUseCase read, this._save) : super(read());

  final SaveCardPackSessionUseCase _save;

  Future<void> _put(CardPackSession? next) async {
    emit(next);
    await _save(next);
  }

  RulesIssue? begin({
    required String id,
    required String template,
    required PackRules rules,
    required List<PoolDeck> pool,
    required List<String> names,
    required int seed,
    required int now,
    bool free = false,
  }) {
    final issue = rules.check(pool, names.length);
    if (issue != null) return issue;
    _put(
      CardPackSession.start(
        id: id,
        template: template,
        rules: rules,
        pool: pool,
        names: names,
        seed: seed,
        createdAt: now,
        free: free,
      ),
    );
    return null;
  }

  Future<void> open(int player, int pack) async {
    final s = state;
    if (s != null) await _put(s.open(player, pack));
  }

  Future<void> toggle(int player, int pack, int card) async {
    final s = state;
    if (s != null) await _put(s.toggle(player, pack, card));
  }

  Future<void> reroll(int player, int pack) async {
    final s = state;
    if (s != null) await _put(s.reroll(player, pack));
  }

  Future<void> validate(int player) async {
    final s = state;
    if (s != null) await _put(s.validate(player));
  }

  Future<void> end() => _put(null);
}
