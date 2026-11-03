import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/domain/gateways/user_admin_gateway.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/invite_user_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/list_users_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/remove_user_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/set_user_admin_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/set_user_blocked_use_case.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';

import 'network_fakes.dart';

class MemoryUserAdmin implements UserAdminGateway {
  MemoryUserAdmin(this.users);

  final Map<String, ManagedUser> users;
  bool forbidden = false;

  @override
  bool get available => true;

  ManagedUser _with(ManagedUser user, {bool? admin, bool? blocked}) =>
      users[user.id] = ManagedUser(
        id: user.id,
        email: user.email,
        name: user.name,
        createdAt: user.createdAt,
        admin: admin ?? user.admin,
        blocked: blocked ?? user.blocked,
        confirmed: user.confirmed,
      );

  @override
  Future<List<ManagedUser>> list() async {
    if (forbidden) throw AdminError.forbidden;
    return users.values.toList();
  }

  @override
  Future<ManagedUser> invite({
    required String email,
    required String name,
  }) async => users['u-$email'] = ManagedUser(
    id: 'u-$email',
    email: email,
    name: name,
    createdAt: DateTime.utc(2026, 11, 3),
  );

  @override
  Future<ManagedUser> setAdmin(String id, {required bool admin}) async =>
      _with(users[id]!, admin: admin);

  @override
  Future<ManagedUser> setBlocked(String id, {required bool blocked}) async =>
      _with(users[id]!, blocked: blocked);

  @override
  Future<void> remove(String id) async => users.remove(id);
}

ManagedUser _user(String id, String name, {bool admin = false}) => ManagedUser(
  id: id,
  email: '$id@example.org',
  name: name,
  admin: admin,
  createdAt: DateTime.utc(2026, 11, 1),
);

({MemoryUserAdmin users, FakeAccounts accounts, AdminCubit cubit}) _setup() {
  final users = MemoryUserAdmin({
    'me': _user('me', 'Gaëtan', admin: true),
    'zoe': _user('zoe', 'Zoé'),
    'alex': _user('alex', 'Alex'),
  });
  final accounts = FakeAccounts(
    current: const Account(id: 'me', email: 'me@example.org', name: 'G'),
  );
  final cubit = AdminCubit(
    ListUsersUseCase(users),
    InviteUserUseCase(users),
    SetUserAdminUseCase(users, accounts),
    SetUserBlockedUseCase(users, accounts),
    RemoveUserUseCase(users, accounts),
  );
  return (users: users, accounts: accounts, cubit: cubit);
}

void main() {
  test('users are listed admins first, then by name', () async {
    final setup = _setup();
    await setup.cubit.load();
    expect(setup.cubit.state.status, AdminStatus.ready);
    expect(setup.cubit.state.users.map((u) => u.id), ['me', 'alex', 'zoe']);
  });

  test('an invite needs a valid email and lands in the list', () async {
    final setup = _setup();
    await setup.cubit.load();
    expect(await setup.cubit.invite('nope', ''), isFalse);
    expect(setup.cubit.state.error, AdminError.invalidEmail);
    expect(await setup.cubit.invite(' Lea@Example.org ', ' Léa '), isTrue);
    expect(setup.cubit.state.notice, AdminNotice.invited);
    expect(setup.users.users['u-lea@example.org']?.name, 'Léa');
  });

  test('roles, blocks and deletions never target your own account', () async {
    final setup = _setup();
    await setup.cubit.load();
    final me = setup.cubit.state.users.first;
    expect(await setup.cubit.toggleAdmin(me), isFalse);
    expect(await setup.cubit.toggleBlocked(me), isFalse);
    expect(await setup.cubit.remove(me), isFalse);
    expect(setup.cubit.state.error, AdminError.self);
    expect(setup.users.users['me']?.admin, isTrue);
  });

  test('another account can be promoted, blocked and deleted', () async {
    final setup = _setup();
    await setup.cubit.load();
    final zoe = setup.users.users['zoe']!;
    await setup.cubit.toggleAdmin(zoe);
    expect(setup.users.users['zoe']?.admin, isTrue);
    await setup.cubit.toggleBlocked(setup.users.users['zoe']!);
    expect(setup.users.users['zoe']?.blocked, isTrue);
    await setup.cubit.remove(setup.users.users['zoe']!);
    expect(setup.cubit.state.users.map((u) => u.id), isNot(contains('zoe')));
    expect(setup.cubit.state.notice, AdminNotice.removed);
  });

  test('a refused list shows the forbidden state', () async {
    final setup = _setup()..users.forbidden = true;
    await setup.cubit.load();
    expect(setup.cubit.state.status, AdminStatus.failed);
    expect(setup.cubit.state.error, AdminError.forbidden);
  });

  test('users decode from the server payload', () {
    final user = ManagedUser.fromJson({
      'id': 'x',
      'email': 'x@example.org',
      'name': '',
      'admin': true,
      'confirmed': false,
      'blocked': true,
      'createdAt': '2026-11-03T13:48:27.774448Z',
      'lastSignInAt': null,
    });
    expect(user.label, 'x@example.org');
    expect(user.admin && user.blocked && !user.confirmed, isTrue);
    expect(user.lastSignInAt, isNull);
  });
}
