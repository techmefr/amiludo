import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Display/fullscreen.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class FullscreenButton extends StatefulWidget {
  const FullscreenButton({super.key});

  @override
  State<FullscreenButton> createState() => _FullscreenButtonState();
}

class _FullscreenButtonState extends State<FullscreenButton> {
  Future<void> _toggle() async {
    await toggleFullscreen();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = isFullscreen;
    return IconButton(
      tooltip: on
          ? context.l10n.fingerExitFullscreen
          : context.l10n.fingerFullscreen,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(Targets.minimum),
        backgroundColor: scheme.surface.withValues(alpha: .55),
        foregroundColor: scheme.onSurfaceVariant,
      ),
      onPressed: _toggle,
      icon: Icon(on ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
    );
  }
}
