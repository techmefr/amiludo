enum SensorSensitivity {
  off(0),
  low(15),
  medium(11),
  high(7);

  const SensorSensitivity(this.shakeThreshold);

  final double shakeThreshold;

  bool get enabled => this != off;

  static SensorSensitivity parse(String? value) =>
      values.firstWhere((level) => level.name == value, orElse: () => medium);
}
