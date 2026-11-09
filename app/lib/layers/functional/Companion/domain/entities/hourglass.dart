enum HourglassPhase { ready, running, paused, finished }

class HourglassSettings {
  const HourglassSettings({this.seconds = 60, this.color = 0xFFE0A526});

  factory HourglassSettings.fromJson(Map<String, dynamic> j) =>
      HourglassSettings(
        seconds: ((j['seconds'] as num?)?.toInt() ?? 60).clamp(1, 86400),
        color: (j['color'] as num? ?? 0xFFE0A526).toInt(),
      );

  final int seconds, color;

  Duration get duration => Duration(seconds: seconds);

  HourglassSettings copyWith({int? seconds, int? color}) => HourglassSettings(
    seconds: seconds ?? this.seconds,
    color: color ?? this.color,
  );

  Map<String, dynamic> toJson() => {'seconds': seconds, 'color': color};
}

class HourglassState {
  HourglassState(this.settings);

  final HourglassSettings settings;
  Duration fallen = Duration.zero;
  int turns = 0;
  bool running = false;

  Duration get remaining => settings.duration - fallen;

  double get lowerFill =>
      fallen.inMicroseconds / settings.duration.inMicroseconds;

  double get upperFill => 1 - lowerFill;

  bool get finished => fallen >= settings.duration;

  HourglassPhase get phase {
    if (finished) return HourglassPhase.finished;
    if (running) return HourglassPhase.running;
    return fallen == Duration.zero
        ? HourglassPhase.ready
        : HourglassPhase.paused;
  }

  void start() {
    if (!finished) running = true;
  }

  void pause() => running = false;

  void tick(Duration elapsed) {
    if (!running) return;
    final next = fallen + elapsed;
    fallen = next > settings.duration ? settings.duration : next;
    if (finished) running = false;
  }

  void turn() {
    if (fallen != Duration.zero) fallen = settings.duration - fallen;
    turns++;
    running = !finished;
  }

  void reset() {
    fallen = Duration.zero;
    running = false;
  }
}
