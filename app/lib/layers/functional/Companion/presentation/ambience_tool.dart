import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Sound/ambient_output.dart';
import 'package:amiludo/layers/technical/Sound/ambient_sounds.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class AmbienceTool extends StatefulWidget {
  const AmbienceTool({super.key, this.output = const SilentAmbientOutput()});
  final AmbientOutput output;

  @override
  State<AmbienceTool> createState() => _AmbienceToolState();
}

class _AmbienceToolState extends State<AmbienceTool> {
  final tool = toolThemeFor('ambience');
  final Map<AmbientKind, double> volumes = {
    for (final kind in AmbientKind.values) kind: 0,
  };

  @override
  void dispose() {
    widget.output.stopAll();
    super.dispose();
  }

  String _name(AmbientKind kind) {
    final l = context.l10n;
    return switch (kind) {
      AmbientKind.rain => l.ambienceRain,
      AmbientKind.wind => l.ambienceWind,
      AmbientKind.fire => l.ambienceFire,
      AmbientKind.storm => l.ambienceStorm,
    };
  }

  IconData _icon(AmbientKind kind) => switch (kind) {
    AmbientKind.rain => Icons.water_drop_outlined,
    AmbientKind.wind => Icons.air,
    AmbientKind.fire => Icons.local_fire_department_outlined,
    AmbientKind.storm => Icons.thunderstorm_outlined,
  };

  void _set(AmbientKind kind, double value) {
    final before = volumes[kind] ?? 0;
    setState(() => volumes[kind] = value);
    if (value <= 0) {
      widget.output.stop(kind.name);
    } else if (before <= 0) {
      widget.output.start(kind.name, ambientLoop(kind), value);
    } else {
      widget.output.setVolume(kind.name, value);
    }
  }

  void _silence() {
    tool.signal();
    widget.output.stopAll();
    setState(() {
      for (final kind in AmbientKind.values) {
        volumes[kind] = 0;
      }
    });
  }

  Widget _channel(AmbientKind kind) {
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final value = volumes[kind] ?? 0;
    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ToolTextureLayer(texture: tool.texture, opacity: .08),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.lg,
              vertical: Space.sm,
            ),
            child: Row(
              children: [
                DeckIcon(_icon(kind), color: ink),
                const SizedBox(width: Space.md),
                SizedBox(
                  width: 88,
                  child: Text(
                    _name(kind),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: value,
                    activeColor: ink,
                    label: _name(kind),
                    semanticFormatterCallback: (v) =>
                        '${_name(kind)} ${(v * 100).round()}%',
                    onChanged: (v) => _set(kind, v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final kind in AmbientKind.values)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: _channel(kind),
            ),
          const SizedBox(height: Space.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _silence,
              icon: const DeckIcon(Icons.pause),
              label: Text(context.l10n.ambienceSilence),
            ),
          ),
        ],
      ),
    ),
  );
}
