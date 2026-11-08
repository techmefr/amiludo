const bankIndex = -1;
const bankStart = 1500;

class BankLedger {
  const BankLedger(this.balances);

  factory BankLedger.begin(int players, {int start = bankStart}) =>
      BankLedger([for (var i = 0; i < players; i++) start]);

  final List<int> balances;

  bool canTransfer(int from, int to, int amount) =>
      amount > 0 &&
      from != to &&
      (from == bankIndex || balances[from] >= amount);

  BankLedger transfer(int from, int to, int amount) {
    if (!canTransfer(from, to, amount)) return this;
    return BankLedger([
      for (final (i, balance) in balances.indexed)
        balance - (i == from ? amount : 0) + (i == to ? amount : 0),
    ]);
  }
}
