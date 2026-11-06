abstract interface class TurnSensor {
  Stream<void> get turns;
}

class NoTurnSensor implements TurnSensor {
  const NoTurnSensor();

  @override
  Stream<void> get turns => const Stream.empty();
}
