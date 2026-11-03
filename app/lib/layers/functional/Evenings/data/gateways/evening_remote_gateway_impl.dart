import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/technical/Network/remote_config.dart';

class EveningRemoteGatewayImpl implements EveningRemoteGateway {
  @override
  bool get available => RemoteConfig.configured;

  Evening _read(Object? row) {
    final map = Map<String, dynamic>.from(row! as Map);
    return Evening.fromJson({
      ...Map<String, dynamic>.from(map['data'] as Map),
      'rsvps': map['rsvps'],
      'published': true,
    }, mine: false);
  }

  @override
  Future<void> publish(Evening evening) => RemoteConfig.client.rpc(
    'publish_evening',
    params: {
      'p_code': evening.code,
      'p_data': {...evening.toJson()}
        ..remove('rsvps')
        ..remove('mine')
        ..remove('published'),
      'p_rsvps': evening.rsvps.map((r) => r.toJson()).toList(),
    },
  );

  @override
  Future<Evening?> fetch(String code) async {
    final row = await RemoteConfig.client.rpc(
      'get_evening',
      params: {'p_code': code},
    );
    return row == null ? null : _read(row);
  }

  @override
  Future<Evening> answer(String code, Rsvp rsvp) async => _read(
    await RemoteConfig.client.rpc(
      'answer_evening',
      params: {'p_code': code, 'p_rsvp': rsvp.toJson()},
    ),
  );

  @override
  Future<void> remove(String code) =>
      RemoteConfig.client.from('evenings').delete().eq('code', code);
}
