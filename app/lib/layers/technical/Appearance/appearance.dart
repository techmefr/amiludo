import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Locale/supported_languages.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';

class Appearance {
  const Appearance({
    this.skin = 'play',
    this.palette = 'play',
    this.mode = 'light',
    this.font = 'LilGrotesk',
    this.shape = 'round',
    this.compact = false,
    this.large = false,
    this.motion = true,
    this.sound = true,
    this.haptics = true,
    this.keepAwake = true,
    this.language = 'fr',
    this.sensors = 'medium',
    this.dice3d = false,
    this.dieSkin = 'classic',
    this.table = 'felt',
  });
  final String skin, palette, mode, font, shape, language, sensors;
  final String dieSkin, table;
  final bool compact, large, motion, keepAwake, sound, haptics, dice3d;
  static const palettes = [
    'play',
    'acid',
    'neon',
    'amber',
    'plasma',
    'lichen',
    'lavender',
    'clay',
    'ocean',
    'honey',
    'rose',
    'gold',
  ];
  static const fonts = [
    'LilGrotesk',
    'SpaceGrotesk',
    'ChakraPetch',
    'Rajdhani',
    'IBMPlexMono',
    'DMSans',
    'Manrope',
    'NunitoSans',
  ];
  Appearance copyWith({
    String? skin,
    String? palette,
    String? mode,
    String? font,
    String? shape,
    bool? compact,
    bool? large,
    bool? motion,
    bool? sound,
    bool? haptics,
    bool? keepAwake,
    String? language,
    String? sensors,
    bool? dice3d,
    String? dieSkin,
    String? table,
  }) => Appearance(
    skin: skin ?? this.skin,
    palette: palette ?? this.palette,
    mode: mode ?? this.mode,
    font: font ?? this.font,
    shape: shape ?? this.shape,
    compact: compact ?? this.compact,
    large: large ?? this.large,
    motion: motion ?? this.motion,
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    keepAwake: keepAwake ?? this.keepAwake,
    language: language ?? this.language,
    sensors: sensors ?? this.sensors,
    dice3d: dice3d ?? this.dice3d,
    dieSkin: dieSkin ?? this.dieSkin,
    table: table ?? this.table,
  );
  Map<String, Object?> toJson() => {
    'skin': skin,
    'palette': palette,
    'mode': mode,
    'font': font,
    'shape': shape,
    'compact': compact,
    'large': large,
    'motion': motion,
    'sound': sound,
    'haptics': haptics,
    'keepAwake': keepAwake,
    'language': language,
    if (sensors != 'medium') 'sensors': sensors,
    if (dice3d) 'dice3d': true,
    if (dieSkin != 'classic') 'dieSkin': dieSkin,
    if (table != 'felt') 'table': table,
  };
  factory Appearance.fromJson(Map<String, dynamic> j) {
    const oldFonts = {
      'space': 'SpaceGrotesk',
      'chakra': 'ChakraPetch',
      'rajdhani': 'Rajdhani',
      'mono': 'IBMPlexMono',
      'dm': 'DMSans',
      'manrope': 'Manrope',
      'nunito': 'NunitoSans',
    };
    final font = oldFonts[j['font']] ?? j['font'] as String? ?? 'SpaceGrotesk';
    final a = Appearance(
      skin: j['skin'] as String? ?? 'paper',
      palette: j['palette'] as String? ?? 'acid',
      mode: j['mode'] as String? ?? 'dark',
      font: font,
      shape: j['shape'] as String? ?? 'cut',
      compact: j['compact'] as bool? ?? j['density'] == 'compact',
      large: j['large'] as bool? ?? false,
      motion: j['motion'] as bool? ?? true,
      sound: j['sound'] as bool? ?? true,
      haptics: j['haptics'] as bool? ?? true,
      keepAwake: j['keepAwake'] as bool? ?? true,
      language: j['language'] as String? ?? 'fr',
      sensors: j['sensors'] as String? ?? 'medium',
      dice3d: j['dice3d'] as bool? ?? false,
      dieSkin: _known(j['dieSkin'], DieSkin.all.map((s) => s.id), 'classic'),
      table: _known(j['table'], TableTheme.all.map((t) => t.id), 'felt'),
    );
    if (!['play', 'cyber', 'orbital', 'paper', 'game'].contains(a.skin) ||
        !palettes.contains(a.palette) ||
        !['dark', 'light', 'system'].contains(a.mode) ||
        !fonts.contains(a.font) ||
        !['cut', 'square', 'soft', 'round'].contains(a.shape) ||
        !isValidLanguage(a.language) ||
        !SensorSensitivity.values.any((level) => level.name == a.sensors)) {
      throw const FormatException('Thème invalide');
    }
    return a;
  }
}

String _known(Object? value, Iterable<String> ids, String fallback) =>
    value is String && ids.contains(value) ? value : fallback;

class StyleProfile {
  const StyleProfile(this.name, this.appearance);
  final String name;
  final Appearance appearance;
  Map<String, Object?> toJson() => {
    'name': name,
    'appearance': appearance.toJson(),
  };
  factory StyleProfile.fromJson(Map<String, dynamic> j) => StyleProfile(
    j['name'] as String,
    Appearance.fromJson(Map<String, dynamic>.from(j['appearance'] as Map)),
  );
}
