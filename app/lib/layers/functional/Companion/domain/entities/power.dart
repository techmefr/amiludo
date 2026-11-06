enum PowerStatus { charging, ready, used }

class PowerSettings {
  const PowerSettings({
    this.name = '',
    this.chargePerEvent = 1,
    this.threshold = 3,
  });

  factory PowerSettings.fromJson(Map<String, dynamic> j) => PowerSettings(
    name: j['name'] as String? ?? '',
    chargePerEvent: (j['chargePerEvent'] as num? ?? 1).toInt(),
    threshold: (j['threshold'] as num? ?? 3).toInt(),
  );

  final String name;
  final int chargePerEvent, threshold;

  Map<String, dynamic> toJson() => {
    'name': name,
    'chargePerEvent': chargePerEvent,
    'threshold': threshold,
  };
}

class PowerState {
  PowerState(this.settings, {int charges = 0, bool used = false})
    : charges = charges.clamp(0, _target(settings)),
      _used = used;

  final PowerSettings settings;
  int charges;
  bool _used;

  static int _target(PowerSettings s) => s.threshold < 1 ? 1 : s.threshold;

  int get target => _target(settings);

  PowerStatus get status {
    if (_used) return PowerStatus.used;
    return charges >= target ? PowerStatus.ready : PowerStatus.charging;
  }

  double get progress => charges / target;

  void charge([int events = 1]) {
    if (_used || events < 1) return;
    charges = (charges + events * settings.chargePerEvent).clamp(0, target);
  }

  bool use() {
    if (status != PowerStatus.ready) return false;
    _used = true;
    charges = 0;
    return true;
  }

  void reset() {
    charges = 0;
    _used = false;
  }
}
