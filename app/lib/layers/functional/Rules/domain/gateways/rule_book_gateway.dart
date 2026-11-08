import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';

abstract class RuleBookGateway {
  RuleBook get current;
  Stream<RuleBook> get changes;
  Future<void> save(RuleBook book);
}
