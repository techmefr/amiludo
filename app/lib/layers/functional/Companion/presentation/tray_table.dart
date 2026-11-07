import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Dice3D/table_painter.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_backdrop.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TrayTable extends StatelessWidget {
  const TrayTable({
    super.key,
    required this.material,
    required this.solid,
    required this.table,
    required this.onTap,
    required this.onPanEnd,
    required this.children,
  });
  final SurfaceMaterial material;
  final bool solid;
  final TableTheme table;
  final VoidCallback? onTap;
  final GestureDragEndCallback onPanEnd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: trayDecoration(scheme, material, solid ? table : null),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onPanEnd: onPanEnd,
          child: Stack(
            children: [
              trayFelt(material, solid),
              if (solid)
                Positioned.fill(child: CustomPaint(painter: TablePainter(table))),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
