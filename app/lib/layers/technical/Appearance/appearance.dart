import 'package:amiludo/layers/technical/Locale/supported_languages.dart';

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
  });
  final String skin, palette, mode, font, shape, language;
  final bool compact, large, motion, keepAwake, sound, haptics;
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
    );
    if (!['play', 'cyber', 'orbital', 'paper', 'game'].contains(a.skin) ||
        !palettes.contains(a.palette) ||
        !['dark', 'light', 'system'].contains(a.mode) ||
        !fonts.contains(a.font) ||
        !['cut', 'square', 'soft', 'round'].contains(a.shape) ||
        !isValidLanguage(a.language)) {
      throw const FormatException('Thème invalide');
    }
    return a;
  }
}

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
