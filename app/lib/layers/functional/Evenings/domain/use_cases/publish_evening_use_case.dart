import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/save_evening_use_case.dart';

class PublishEveningUseCase {
  PublishEveningUseCase(this._accounts, this._remote, this._save);

  final AccountGateway _accounts;
  final EveningRemoteGateway _remote;
  final SaveEveningUseCase _save;

  Future<Evening> call(Evening evening) async {
    if (!_remote.available) throw const AccountUnavailable();
    if (_accounts.current == null) {
      throw AccountError.signInRequired;
    }
    final published = evening.copyWith(published: true);
    await _save(published);
    return published;
  }
}
