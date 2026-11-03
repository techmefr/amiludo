class GameClock {
  const GameClock({
    this.remainingMs = 150000,
    this.deadlineMs,
    this.incrementMs = 0,
    this.durationMs = 150000,
  });
  final int remainingMs, incrementMs, durationMs;
  final int? deadlineMs;
  bool get isRunning => deadlineMs != null;
  int remainingAt(int now) =>
      deadlineMs == null ? remainingMs : (deadlineMs! - now).clamp(0, 86400000);
  GameClock start(int now) => GameClock(
    remainingMs: remainingMs,
    deadlineMs: now + remainingMs,
    incrementMs: incrementMs,
    durationMs: durationMs,
  );
  GameClock pause(int now) => GameClock(
    remainingMs: remainingAt(now),
    incrementMs: incrementMs,
    durationMs: durationMs,
  );
  GameClock reset() => GameClock(
    remainingMs: durationMs,
    incrementMs: incrementMs,
    durationMs: durationMs,
  );
  GameClock increment(int now) => GameClock(
    remainingMs: remainingAt(now) + incrementMs,
    incrementMs: incrementMs,
    durationMs: durationMs,
  );
  Map<String, Object?> toJson() => {
    'remainingMs': remainingMs,
    'deadlineMs': deadlineMs,
    'incrementMs': incrementMs,
    'durationMs': durationMs,
  };
  factory GameClock.fromJson(Map<String, dynamic> j) {
    final remaining = j['remainingMs'] as int,
        increment = j['incrementMs'] as int? ?? 0,
        duration = j['durationMs'] as int? ?? remaining;
    if (remaining < 0 ||
        remaining > 86400000 ||
        duration < 1000 ||
        duration > 86400000 ||
        increment < 0 ||
        increment > 600000) {
      throw const FormatException('Minuteur invalide');
    }
    return GameClock(
      remainingMs: remaining,
      deadlineMs: j['deadlineMs'] as int?,
      incrementMs: increment,
      durationMs: duration,
    );
  }
}

class MonotonicTime {
  MonotonicTime() : _base = DateTime.now().millisecondsSinceEpoch {
    _watch.start();
  }
  final int _base;
  final Stopwatch _watch = Stopwatch();
  int get now => _base + _watch.elapsedMilliseconds;
}

String clockText(int milliseconds) {
  final seconds = (milliseconds / 1000).ceil();
  final minutes = seconds ~/ 60;
  return '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class ClockSnapshot {
  const ClockSnapshot(this.clock, this.bankMode, this.reverse);
  final GameClock clock;
  final bool bankMode, reverse;
  Map<String, Object?> toJson() => {
    'clock': clock.toJson(),
    'bankMode': bankMode,
    'reverse': reverse,
  };
  factory ClockSnapshot.fromJson(Map<String, dynamic> j) => ClockSnapshot(
    GameClock.fromJson(Map<String, dynamic>.from(j['clock'] as Map)),
    j['bankMode'] as bool? ?? false,
    j['reverse'] as bool? ?? false,
  );
}
