import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/hourglass.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/sand_scene.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const hourglassPresets = [30, 60, 120, 300];

class HourglassTool extends StatefulWidget {
  const HourglassTool({
    super.key,
    this.initial = const HourglassSettings(),
    this.sensor = const NoTurnSensor(),
    this.requestMotionAccess,
  });
  final HourglassSettings initial;
  final TurnSensor sensor;
  final Future<bool> Function()? requestMotionAccess;

  @override
  State<HourglassTool> createState() => _HourglassToolState();
}

class _HourglassToolState extends State<HourglassTool> {
  late HourglassSettings settings = widget.initial;
  bool requestingMotion = false;
  bool motionAuthorized = false;

  Future<void> authorizeMotion() async {
    final request = widget.requestMotionAccess;
    if (request == null || requestingMotion) return;
    setState(() => requestingMotion = true);
    final allowed = await request();
    if (!mounted) return;
    setState(() {
      requestingMotion = false;
      motionAuthorized = allowed;
    });
    if (!allowed) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.l10n.hourglassMotionDenied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SandScene(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final seconds in hourglassPresets)
                  SandPill(
                    label: context.l10n.hourglassSeconds(seconds),
                    selected: settings.seconds == seconds,
                    onPressed: () => setState(
                      () => settings = settings.copyWith(seconds: seconds),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Space.xl),
            if (widget.requestMotionAccess != null && !motionAuthorized)
              SandPill(
                label: context.l10n.hourglassEnableMotion,
                onPressed: requestingMotion ? null : authorizeMotion,
              ),
            HourglassView(
              settings: settings,
              sensor: widget.requestMotionAccess == null || motionAuthorized
                  ? widget.sensor
                  : const NoTurnSensor(),
            ),
          ],
        ),
      ),
    ),
  );
}
