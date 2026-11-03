import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class AnswerEveningUseCase {
  AnswerEveningUseCase(
    this._workspace,
    this._evenings,
    this._remote,
    this._accounts,
  );

  final WorkspaceGateway _workspace;
  final EveningsGateway _evenings;
  final EveningRemoteGateway _remote;
  final AccountGateway _accounts;

  Future<Evening> call(
    String eveningId,
    RsvpAnswer answer, {
    String? guestId,
    String? guestName,
    DateTime? now,
  }) async {
    final evening = _evenings.current.evenings.firstWhere(
      (e) => e.id == eveningId,
    );
    final rsvp = _rsvp(evening, answer, guestId, guestName, now);
    final updated = evening.published && _remote.available
        ? await _remote.answer(evening.code, rsvp)
        : evening.withRsvp(rsvp);
    final kept = Evening.fromJson({
      ...updated.toJson(),
      'id': evening.id,
    }, mine: evening.mine);
    final evenings = _evenings.current.evenings;
    await _evenings.save(
      EveningAgenda(
        evenings: [kept, ...evenings.where((e) => e.id != eveningId)],
      ),
    );
    return kept;
  }

  Rsvp _rsvp(
    Evening evening,
    RsvpAnswer answer,
    String? guestId,
    String? guestName,
    DateTime? now,
  ) {
    final at = (now ?? DateTime.now()).toUtc();
    if (guestId != null) {
      if (!evening.mine) throw const FormatException('Réservé à l’hôte');
      return Rsvp(id: guestId, name: guestName ?? '?', answer: answer, at: at);
    }
    final account = _accounts.current;
    if (evening.published && account == null) {
      throw const AccountFailure('Connectez-vous pour répondre');
    }
    final name = account?.name ?? _workspace.current.nickname;
    return Rsvp(
      id: account?.id ?? 'me',
      name: name.isEmpty ? '?' : name,
      answer: answer,
      at: at,
    );
  }
}
