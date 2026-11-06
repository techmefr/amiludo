import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/hourglass.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const hourglassPresets = [30, 60, 120, 300];

class HourglassTool extends StatefulWidget {
  const HourglassTool({super.key, this.initial = const HourglassSettings()});
  final HourglassSettings initial;

  @override
  State<HourglassTool> createState() => _HourglassToolState();
}

class _HourglassToolState extends State<HourglassTool> {
  late HourglassSettings settings = widget.initial;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final seconds in hourglassPresets)
              ChoiceChip(
                label: Text(context.l10n.hourglassSeconds(seconds)),
                selected: settings.seconds == seconds,
                onSelected: (_) => setState(
                  () => settings = settings.copyWith(seconds: seconds),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.xl),
        HourglassView(settings: settings),
      ],
    ),
  );
}
