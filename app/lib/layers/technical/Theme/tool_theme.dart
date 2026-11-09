import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Sound/tool_sounds.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum ToolTexture { plain, felt, glass, parchment, paper, deck, frame, tactile }

enum ToolHeader { plain, tinted, ribbon }

enum ToolMotion { snap, tumble, flow, drift, flip }

enum ToolHaptic { selection, impact }

class ToolTheme {
  const ToolTheme({
    required this.accent,
    this.texture = ToolTexture.plain,
    this.header = ToolHeader.tinted,
    this.motion = ToolMotion.snap,
    this.haptic = ToolHaptic.selection,
    this.weight = 1,
  });
  final Color accent;
  final ToolTexture texture;
  final ToolHeader header;
  final ToolMotion motion;
  final ToolHaptic haptic;
  final double weight;

  Curve get curve => switch (motion) {
    ToolMotion.snap => Motion.spring,
    ToolMotion.tumble => Curves.bounceOut,
    ToolMotion.flow => Curves.easeInOutCubic,
    ToolMotion.drift => Curves.easeOut,
    ToolMotion.flip => Curves.easeInOutBack,
  };

  Duration duration(BuildContext context) =>
      Motion.of(context, switch (motion) {
        ToolMotion.snap => Motion.fast,
        ToolMotion.tumble || ToolMotion.flip => Motion.base,
        ToolMotion.flow || ToolMotion.drift => Motion.slow,
      });

  ToolSoundKind get soundKind => switch (texture) {
    ToolTexture.felt => ToolSoundKind.thud,
    ToolTexture.tactile || ToolTexture.frame => ToolSoundKind.knock,
    ToolTexture.parchment || ToolTexture.paper => ToolSoundKind.rustle,
    ToolTexture.deck => ToolSoundKind.snap,
    ToolTexture.glass => ToolSoundKind.chime,
    ToolTexture.plain => ToolSoundKind.tick,
  };

  Future<void> signal() {
    ToolSounds.play(soundKind);
    return _vibrate();
  }

  Future<void> _vibrate() => switch ((haptic, texture)) {
    (ToolHaptic.selection, _) => DeckHaptics.selection(),
    (ToolHaptic.impact, ToolTexture.felt) => DeckHaptics.heavy(),
    (ToolHaptic.impact, ToolTexture.tactile || ToolTexture.frame) =>
      DeckHaptics.knock(),
    (
      ToolHaptic.impact,
      ToolTexture.parchment || ToolTexture.paper || ToolTexture.deck,
    ) =>
      DeckHaptics.ripple(),
    (ToolHaptic.impact, _) => DeckHaptics.impact(),
  };

  Color surface(BuildContext context, {double? mix}) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Color.lerp(
      theme.colorScheme.surface,
      accent,
      mix ?? (dark ? .16 : .1),
    )!;
  }

  Color ink(Color background, {double ratio = 4.5}) {
    final towardsDark = background.computeLuminance() > .5;
    final target = towardsDark ? Colors.black : Colors.white;
    var color = accent;
    for (
      var step = 1;
      step <= 20 && _contrast(color, background) < ratio;
      step++
    ) {
      color = Color.lerp(accent, target, step / 20)!;
    }
    return color;
  }
}

double _contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  final light = x > y ? x : y, dark = x > y ? y : x;
  return (light + .05) / (dark + .05);
}

double toolContrast(Color a, Color b) => _contrast(a, b);

const toolThemes = <String, ToolTheme>{
  'dice': ToolTheme(
    accent: Color(0xff1F7A4D),
    texture: ToolTexture.felt,
    motion: ToolMotion.tumble,
    haptic: ToolHaptic.impact,
    weight: 1.2,
  ),
  'dice-tray': ToolTheme(
    accent: Color(0xff1F7A4D),
    texture: ToolTexture.felt,
    header: ToolHeader.ribbon,
    motion: ToolMotion.tumble,
    haptic: ToolHaptic.impact,
    weight: 1.2,
  ),
  'hourglass': ToolTheme(
    accent: Color(0xffC48A1A),
    texture: ToolTexture.glass,
    motion: ToolMotion.drift,
    weight: .8,
  ),
  'stopwatch': ToolTheme(
    accent: Color(0xff2F7D8C),
    texture: ToolTexture.glass,
    motion: ToolMotion.snap,
    haptic: ToolHaptic.impact,
    weight: .8,
  ),
  'chess-clock': ToolTheme(
    accent: Color(0xff4A5D73),
    texture: ToolTexture.tactile,
    motion: ToolMotion.snap,
    haptic: ToolHaptic.impact,
    weight: 1.2,
  ),
  'turn-timer': ToolTheme(
    accent: Color(0xff2E7D6B),
    texture: ToolTexture.plain,
    motion: ToolMotion.snap,
    weight: .9,
  ),
  'metronome': ToolTheme(
    accent: Color(0xff1F8A70),
    texture: ToolTexture.tactile,
    motion: ToolMotion.snap,
    haptic: ToolHaptic.selection,
    weight: 1.1,
  ),
  'phases': ToolTheme(
    accent: Color(0xff6A5BB0),
    texture: ToolTexture.glass,
    motion: ToolMotion.flow,
    haptic: ToolHaptic.impact,
    weight: .9,
  ),
  'countdown': ToolTheme(
    accent: Color(0xffB5532B),
    texture: ToolTexture.glass,
    motion: ToolMotion.flow,
    haptic: ToolHaptic.impact,
    weight: .9,
  ),
  'timer': ToolTheme(
    accent: Color(0xffC48A1A),
    texture: ToolTexture.glass,
    motion: ToolMotion.flow,
    weight: .8,
  ),
  'scores': ToolTheme(
    accent: Color(0xff2F8F83),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'life': ToolTheme(
    accent: Color(0xffC2493D),
    texture: ToolTexture.tactile,
    header: ToolHeader.ribbon,
    haptic: ToolHaptic.impact,
    weight: 1.4,
  ),
  'tally': ToolTheme(
    accent: Color(0xff3F6FB0),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'ranking': ToolTheme(
    accent: Color(0xffB38A1D),
    texture: ToolTexture.paper,
    motion: ToolMotion.flip,
  ),
  'sheet': ToolTheme(
    accent: Color(0xff2F8F83),
    texture: ToolTexture.paper,
    header: ToolHeader.ribbon,
    motion: ToolMotion.flow,
  ),
  'stats': ToolTheme(
    accent: Color(0xff3F6FB0),
    texture: ToolTexture.paper,
    header: ToolHeader.ribbon,
    motion: ToolMotion.flow,
  ),
  'buzzer': ToolTheme(
    accent: Color(0xffD2603F),
    texture: ToolTexture.tactile,
    haptic: ToolHaptic.impact,
    weight: 1.4,
  ),
  'clocks': ToolTheme(
    accent: Color(0xffB5762A),
    texture: ToolTexture.paper,
    motion: ToolMotion.flow,
  ),
  'sport': ToolTheme(
    accent: Color(0xff2F8F83),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'markers': ToolTheme(
    accent: Color(0xff6F4FB0),
    texture: ToolTexture.deck,
    motion: ToolMotion.flip,
  ),
  'bank': ToolTheme(
    accent: Color(0xffB5762A),
    texture: ToolTexture.paper,
    weight: 1.4,
  ),
  'auction': ToolTheme(
    accent: Color(0xffC2493D),
    texture: ToolTexture.tactile,
    haptic: ToolHaptic.impact,
    weight: 1.4,
  ),
  'tournament': ToolTheme(
    accent: Color(0xff3F6FB0),
    texture: ToolTexture.parchment,
    header: ToolHeader.ribbon,
    motion: ToolMotion.flow,
  ),
  'balance': ToolTheme(accent: Color(0xff2F8F83), motion: ToolMotion.flow),
  'league': ToolTheme(
    accent: Color(0xffB38A1D),
    texture: ToolTexture.paper,
    motion: ToolMotion.flow,
  ),
  'solo': ToolTheme(
    accent: Color(0xff8A65D8),
    texture: ToolTexture.deck,
    motion: ToolMotion.flow,
  ),
  'units': ToolTheme(
    accent: Color(0xff5A4FB0),
    texture: ToolTexture.frame,
    motion: ToolMotion.flow,
  ),
  'turns': ToolTheme(
    accent: Color(0xff5A4FB0),
    texture: ToolTexture.frame,
    header: ToolHeader.ribbon,
    motion: ToolMotion.flow,
  ),
  'first-player': ToolTheme(
    accent: Color(0xffD2603F),
    motion: ToolMotion.flow,
    haptic: ToolHaptic.impact,
  ),
  'counter-life': ToolTheme(
    accent: Color(0xffC2493D),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'counter-points': ToolTheme(
    accent: Color(0xff2F8F83),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'counter-chips': ToolTheme(
    accent: Color(0xff3F6FB0),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'counter-pot': ToolTheme(
    accent: Color(0xffB5762A),
    texture: ToolTexture.tactile,
    weight: 1.4,
  ),
  'map': ToolTheme(
    accent: Color(0xff8A5A2B),
    texture: ToolTexture.parchment,
    header: ToolHeader.ribbon,
    motion: ToolMotion.drift,
    weight: .9,
  ),
  'character': ToolTheme(
    accent: Color(0xff9A5B2E),
    texture: ToolTexture.frame,
    header: ToolHeader.ribbon,
    motion: ToolMotion.flow,
  ),
  'heroes': ToolTheme(
    accent: Color(0xff5A4FB0),
    texture: ToolTexture.frame,
    header: ToolHeader.ribbon,
    motion: ToolMotion.flow,
  ),
  'picker': ToolTheme(
    accent: Color(0xffD2603F),
    texture: ToolTexture.plain,
    motion: ToolMotion.snap,
    haptic: ToolHaptic.impact,
  ),
  'teams': ToolTheme(accent: Color(0xff3F6FB0), motion: ToolMotion.flow),
  'wheel': ToolTheme(
    accent: Color(0xffB4558A),
    motion: ToolMotion.flip,
    haptic: ToolHaptic.impact,
  ),
  'coin': ToolTheme(
    accent: Color(0xffB38A1D),
    motion: ToolMotion.flip,
    haptic: ToolHaptic.impact,
  ),
  'order': ToolTheme(accent: Color(0xff3F6FB0), texture: ToolTexture.deck),
  'number': ToolTheme(accent: Color(0xff5A4FB0), texture: ToolTexture.tactile),
  'bag': ToolTheme(accent: Color(0xff8A5A2B), texture: ToolTexture.deck),
  'roles': ToolTheme(
    accent: Color(0xff6F4FB0),
    texture: ToolTexture.deck,
    motion: ToolMotion.flip,
  ),
  'deck': ToolTheme(
    accent: Color(0xffA3274B),
    texture: ToolTexture.deck,
    motion: ToolMotion.flip,
    haptic: ToolHaptic.impact,
    weight: 1.1,
  ),
  'rules': ToolTheme(
    accent: Color(0xff8A5A2B),
    texture: ToolTexture.parchment,
    header: ToolHeader.ribbon,
    motion: ToolMotion.drift,
    weight: .9,
  ),
  'vote': ToolTheme(
    accent: Color(0xff2F5D8C),
    texture: ToolTexture.paper,
    motion: ToolMotion.snap,
    haptic: ToolHaptic.impact,
  ),
  'impostor': ToolTheme(
    accent: Color(0xff6F4FB0),
    texture: ToolTexture.deck,
    motion: ToolMotion.flip,
    haptic: ToolHaptic.impact,
  ),
  'oracle': ToolTheme(
    accent: Color(0xff7B4B94),
    texture: ToolTexture.parchment,
    motion: ToolMotion.flip,
    haptic: ToolHaptic.impact,
  ),
  'challenges': ToolTheme(
    accent: Color(0xffC2493D),
    texture: ToolTexture.deck,
    motion: ToolMotion.flip,
    haptic: ToolHaptic.impact,
  ),
  'journal': ToolTheme(
    accent: Color(0xff8A5A2B),
    texture: ToolTexture.paper,
    header: ToolHeader.ribbon,
    motion: ToolMotion.drift,
    weight: .9,
  ),
  'ambience': ToolTheme(
    accent: Color(0xff2F7D6F),
    texture: ToolTexture.glass,
    motion: ToolMotion.flow,
  ),
  'npc': ToolTheme(accent: Color(0xff9A5B2E), texture: ToolTexture.deck),
  'tavern': ToolTheme(accent: Color(0xff9A5B2E), texture: ToolTexture.deck),
  'encounter': ToolTheme(accent: Color(0xffC2493D), texture: ToolTexture.deck),
  'quest': ToolTheme(accent: Color(0xff8A5A2B), texture: ToolTexture.deck),
  'treasure': ToolTheme(accent: Color(0xffB38A1D), texture: ToolTexture.deck),
  'villain': ToolTheme(accent: Color(0xff7A3B8F), texture: ToolTexture.deck),
  'town': ToolTheme(accent: Color(0xff3F6FB0), texture: ToolTexture.deck),
  'magicitem': ToolTheme(accent: Color(0xff6F4FB0), texture: ToolTexture.deck),
  'weather': ToolTheme(accent: Color(0xff3F7FA8), texture: ToolTexture.deck),
  'place': ToolTheme(accent: Color(0xff2F8F83), texture: ToolTexture.deck),
  'dilemma': ToolTheme(accent: Color(0xffB4558A), texture: ToolTexture.deck),
  'rumour': ToolTheme(accent: Color(0xff8A5A2B), texture: ToolTexture.deck),
  'trait': ToolTheme(accent: Color(0xff5A4FB0), texture: ToolTexture.deck),
  'twist': ToolTheme(accent: Color(0xffD2603F), texture: ToolTexture.deck),
  'bestiary': ToolTheme(
    accent: Color(0xff2F6B4F),
    texture: ToolTexture.parchment,
  ),
  'scenes': ToolTheme(accent: Color(0xff8A4B2A), texture: ToolTexture.paper),
  'gmtables': ToolTheme(accent: Color(0xff3A5BA0), texture: ToolTexture.deck),
  'worldmap': ToolTheme(
    accent: Color(0xff6B4E2E),
    texture: ToolTexture.parchment,
  ),
  'combat': ToolTheme(
    accent: Color(0xffB4232F),
    texture: ToolTexture.frame,
    haptic: ToolHaptic.impact,
    weight: 1.2,
  ),
};

const _fallback = ToolTheme(accent: Color(0xff59BBAA));

ToolTheme toolThemeFor(String id) => toolThemes[id] ?? _fallback;
