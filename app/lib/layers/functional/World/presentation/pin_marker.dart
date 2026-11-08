import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/presentation/world_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const pinColors = {
  PinKind.place: Color(0xff2F6B4F),
  PinKind.npc: Color(0xff3A5BA0),
  PinKind.scene: Color(0xff8A4B2A),
  PinKind.danger: Color(0xffB4232F),
};

const _labelWidth = 140.0;
const pinInk = Color(0xffFFFFFF);

IconData pinIcon(PinKind kind) => switch (kind) {
  PinKind.place => Icons.place,
  PinKind.npc => Icons.person,
  PinKind.scene => Icons.theater_comedy,
  PinKind.danger => Icons.warning_amber_rounded,
};

class PinMarker extends StatelessWidget {
  const PinMarker({
    super.key,
    required this.pin,
    required this.center,
    required this.scale,
    required this.draggable,
    required this.onTap,
    required this.onMove,
  });
  final MapPin pin;
  final Offset center;
  final double scale;
  final bool draggable;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = pinColors[pin.kind]!;
    return Positioned(
      left: center.dx - _labelWidth / 2,
      top: center.dy - Targets.minimum / 2,
      width: _labelWidth,
      child: Semantics(
        button: true,
        label: l.worldPinLabel(pin.title, context.pinKindLabel(pin.kind)),
        child: GestureDetector(
          onTap: onTap,
          onPanUpdate: draggable ? (d) => onMove(d.delta / scale) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Targets.minimum - 8,
                height: Targets.minimum - 8,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: pinInk, width: 2),
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Color(0x66000000)),
                  ],
                ),
                child: Icon(pinIcon(pin.kind), color: pinInk, size: 20),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: .85,
                    ),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    pin.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
