import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/functional/Rules/domain/gateways/rule_book_gateway.dart';

class ReadRuleBookUseCase {
  ReadRuleBookUseCase(this._rules);
  final RuleBookGateway _rules;

  RuleBook call() => _rules.current;
}

class SaveRuleBookUseCase {
  SaveRuleBookUseCase(this._rules);
  final RuleBookGateway _rules;

  Future<void> call(RuleBook book) => _rules.save(book);
}
