import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/save_nickname_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_up_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/answer_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/fetch_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/publish_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/save_evening_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';

import 'fakes.dart';
import 'network_fakes.dart';

final start = DateTime.utc(2026, 11, 20, 19);

Evening night({int seats = 3, bool mine = true}) => Evening(
  id: 'e1',
  code: 'ABCDEFGH',
  title: 'Soirée Skull',
  startsAt: start,
  hostName: 'Camille',
  seats: seats,
  mine: mine,
);

Rsvp answer(String id, RsvpAnswer value, int minute) => Rsvp(
  id: id,
  name: id,
  answer: value,
  at: start.subtract(Duration(days: 1, minutes: -minute)),
);

void main() {
  _ruleTests();
  _localTests();
  _onlineTests();
}

void _ruleTests() {
  test('first come first seated, the rest wait in order', () {
    var e = night()
        .withRsvp(answer('Léa', RsvpAnswer.yes, 1))
        .withRsvp(answer('Sam', RsvpAnswer.yes, 2))
        .withRsvp(answer('Alex', RsvpAnswer.yes, 3))
        .withRsvp(answer('Zoé', RsvpAnswer.maybe, 4));
    expect(e.going.map((r) => r.id), ['Léa', 'Sam']);
    expect(e.waitlist.map((r) => r.id), ['Alex']);
    expect(e.maybe.map((r) => r.id), ['Zoé']);
    e = e.withRsvp(answer('Léa', RsvpAnswer.yes, 9));
    expect(e.going.map((r) => r.id), ['Léa', 'Sam']);
    e = e.withRsvp(answer('Léa', RsvpAnswer.no, 10));
    expect(e.going.map((r) => r.id), ['Sam', 'Alex']);
    expect(e.declined.map((r) => r.id), ['Léa']);
    expect(
      night(seats: 0).withRsvp(answer('A', RsvpAnswer.yes, 1)).waitlist,
      isEmpty,
    );
    final restored = Evening.fromJson(
      jsonDecode(jsonEncode(e.toJson())) as Map<String, dynamic>,
    );
    expect(restored.waitlist.length, e.waitlist.length);
    expect(restored.startsAt, start);
  });

  test('backups without nickname or evenings still load', () {
    final old = const Workspace().toJson()
      ..remove('nickname')
      ..remove('evenings');
    final restored = Workspace.fromJson(old);
    expect(restored.nickname, '');
    expect(restored.evenings, isEmpty);
    final full = Workspace.fromJson(
      const Workspace(nickname: 'Camille')
          .copyWith(evenings: [night()])
          .toJson(),
    );
    expect(full.nickname, 'Camille');
    expect(full.evenings.single.code, 'ABCDEFGH');
  });
}

void _localTests() {
  test('the host records friends answers without a server', () async {
    final accounts = FakeAccounts(available: false);
    final remote = MemoryEvenings(available: false, accounts: accounts);
    final workspace = MemoryWorkspace();
    await SaveEveningUseCase(workspace, remote)(night());
    final answerUseCase = AnswerEveningUseCase(workspace, remote, accounts);
    await answerUseCase(
      'e1',
      RsvpAnswer.yes,
      guestId: 'friend:a',
      guestName: 'Alex',
    );
    final e = workspace.current.evenings.single;
    expect(e.going.single.name, 'Alex');
    expect(remote.stored, isEmpty);
    expect(
      () => PublishEveningUseCase(
        accounts,
        remote,
        SaveEveningUseCase(workspace, remote),
      )(e),
      throwsA(isA<AccountUnavailable>()),
    );
    expect(await FetchEveningUseCase(workspace, remote)('abcdefgh'), isNotNull);
    expect(
      () => SaveEveningUseCase(workspace, remote)(night().copyWith(title: ' ')),
      throwsFormatException,
    );
  });

  test('profile names are checked and kept', () async {
    final workspace = MemoryWorkspace();
    await SaveNicknameUseCase(workspace)('  Camille ');
    expect(workspace.current.nickname, 'Camille');
    expect(
      () => SaveNicknameUseCase(workspace)(' '),
      throwsA(AccountError.invalidName),
    );
    final accounts = FakeAccounts();
    final signUp = SignUpUseCase(accounts, MemoryWorkspace());
    expect(
      () => signUp(email: 'nope', password: 'longenough', name: 'Léa'),
      throwsA(AccountError.invalidEmail),
    );
    expect(
      () => signUp(email: 'lea@example.test', password: 'short', name: 'Léa'),
      throwsA(AccountError.invalidPassword),
    );
    expect(accounts.signUps, isEmpty);
  });
}

void _onlineTests() {
  test('a published night collects sign-ups from accounts', () async {
    final hostAccounts = FakeAccounts(
      current: const Account(id: 'host', email: 'h@x.test', name: 'Camille'),
    );
    final server = MemoryEvenings(accounts: hostAccounts);
    final hostSpace = MemoryWorkspace();
    final publish = PublishEveningUseCase(
      hostAccounts,
      server,
      SaveEveningUseCase(hostSpace, server),
    );
    await publish(night(seats: 2));
    expect(server.stored['ABCDEFGH']!.published, isTrue);

    final guestAccounts = FakeAccounts();
    final guestServer = MemoryEvenings(accounts: guestAccounts)
      ..stored.addAll(server.stored);
    final guestSpace = MemoryWorkspace();
    final fetched = await FetchEveningUseCase(guestSpace, guestServer)(
      'ABCD-EFGH',
    );
    expect(fetched!.mine, isFalse);
    final reply = AnswerEveningUseCase(guestSpace, guestServer, guestAccounts);
    expect(
      () => reply(fetched.id, RsvpAnswer.yes),
      throwsA(AccountError.signInRequired),
    );
    await SignUpUseCase(guestAccounts, guestSpace)(
      email: 'lea@example.test',
      password: 'longenough',
      name: 'Léa',
    );
    final updated = await reply(fetched.id, RsvpAnswer.yes);
    expect(updated.going.single.id, 'u-lea@example.test');
    expect(guestSpace.current.nickname, 'Léa');
    expect(
      () => reply(fetched.id, RsvpAnswer.yes, guestId: 'x', guestName: 'X'),
      throwsA(EveningError.hostOnly),
    );
  });
}
