import 'package:amiludo/layers/functional/Scenes/domain/entities/storyline.dart';
import 'package:amiludo/layers/functional/Scenes/domain/gateways/storyline_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class StorylineGatewayImpl extends StoredDocument<Storyline>
    implements StorylineGateway {
  StorylineGatewayImpl(super.store)
    : super(
        id: 'scenes',
        empty: const Storyline(),
        fromJson: _decode,
        toJson: (storyline) => {'storyline': storyline.toJson()},
      );

  static Storyline _decode(Map<String, dynamic> json) {
    final stored = json['storyline'];
    if (stored is! Map) return const Storyline();
    return Storyline.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
