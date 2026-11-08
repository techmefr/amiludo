import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/functional/Rules/domain/gateways/rule_book_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class RuleBookGatewayImpl extends StoredDocument<RuleBook>
    implements RuleBookGateway {
  RuleBookGatewayImpl(super.store)
    : super(
        id: 'rules',
        empty: const RuleBook(),
        fromJson: RuleBook.fromJson,
        toJson: (book) => book.toJson(),
        legacyId: 'rules-legacy',
      );

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
