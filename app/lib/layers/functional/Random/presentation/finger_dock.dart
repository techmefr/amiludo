import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class FingerDock extends StatelessWidget {
  const FingerDock({
    super.key,
    required this.visible,
    required this.mode,
    required this.onMode,
    required this.onOptions,
  });
  final bool visible;
  final FingerMode mode;
  final ValueChanged<FingerMode> onMode;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: ExcludeFocus(
            excluding: !visible,
            child: IgnorePointer(
              ignoring: !visible,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: Motion.of(context, Motion.base),
                child: Material(
                  color: scheme.surface.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(Radii.pill),
                  child: Padding(
                    padding: const EdgeInsets.all(Space.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: FingerModeSelector(
                              mode: mode,
                              onChanged: onMode,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.fingerOptions,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(Targets.minimum),
                          ),
                          onPressed: onOptions,
                          icon: const Icon(Icons.tune_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
