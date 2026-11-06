import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_geometry.dart';
import 'package:amiludo/layers/technical/Theme/icon_catalog.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const mapLabelWidth = 120.0;
const mapTailHeight = 4.0;
const mapMarkerBorder = 2.0;

class MapMarkerView extends StatelessWidget {
  const MapMarkerView({super.key, required this.marker, required this.center});
  final MapMarker marker;
  final Offset center;

  @override
  Widget build(BuildContext context) {
    final fill = Color(marker.color);
    final onFill = fill.computeLuminance() > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    final scheme = Theme.of(context).colorScheme;
    final pin = marker.kind == MapMarkerKind.pin;
    return Positioned(
      left: center.dx - mapLabelWidth / 2,
      top: center.dy - mapMarkerSize / 2,
      width: mapLabelWidth,
      child: IgnorePointer(
        child: Semantics(
          label: marker.label.isEmpty ? marker.icon : marker.label,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: mapMarkerSize,
                height: mapMarkerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  shape: pin ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: pin ? null : BorderRadius.circular(Radii.md),
                  border: Border.all(
                    color: scheme.surface,
                    width: mapMarkerBorder,
                  ),
                ),
                child: CatalogIcon(marker.icon, color: onFill),
              ),
              if (pin)
                Container(
                  width: mapMarkerBorder,
                  height: mapTailHeight,
                  color: fill,
                ),
              if (marker.label.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: Space.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.sm,
                    vertical: Space.xs,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    marker.label,
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
