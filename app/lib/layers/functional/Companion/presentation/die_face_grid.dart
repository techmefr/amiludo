import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_face_ops.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class DieFaceGrid extends StatelessWidget {
  const DieFaceGrid({
    super.key,
    required this.design,
    required this.current,
    required this.onTap,
    required this.onChange,
  });
  final DieDesign design;
  final int current;
  final ValueChanged<int> onTap;
  final void Function(DieDesign next, {int? focus}) onChange;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final body = Color(design.color);
    Widget op(String tip, IconData icon, VoidCallback? tap) => IconButton(
      tooltip: tip,
      constraints: const BoxConstraints.tightFor(
        width: Targets.minimum,
        height: Targets.minimum,
      ),
      icon: DeckIcon(icon),
      onPressed: tap,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (var i = 0; i < design.faces.length; i++)
              Semantics(
                button: true,
                selected: i == current,
                label: l.diceFaceEdit(i + 1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.md),
                  onTap: () => onTap(i),
                  child: Container(
                    width: Targets.minimum + Space.sm,
                    height: Targets.minimum + Space.sm,
                    decoration: BoxDecoration(
                      color: body,
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(
                        color: i == current
                            ? scheme.accentInk
                            : scheme.outlineVariant,
                        width: i == current ? 3 : 1,
                      ),
                    ),
                    child: ExcludeSemantics(
                      child: DieFaceView(
                        face: design.faces[i],
                        body: body,
                        size: Targets.minimum,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Row(
          children: [
            op(
              l.diceFaceMoveEarlier,
              Icons.arrow_back,
              current == 0
                  ? null
                  : () => onChange(
                      design.moved(current, current - 1),
                      focus: current - 1,
                    ),
            ),
            op(
              l.diceFaceMoveLater,
              Icons.arrow_forward,
              current >= design.faces.length - 1
                  ? null
                  : () => onChange(
                      design.moved(current, current + 1),
                      focus: current + 1,
                    ),
            ),
            op(
              l.diceFaceDuplicate,
              Icons.copy_outlined,
              design.faces.length >= maxDieFaces
                  ? null
                  : () => onChange(
                      design.duplicated(current),
                      focus: current + 1,
                    ),
            ),
            op(
              l.diceFaceRemove,
              Icons.remove_circle_outline,
              design.faces.length <= minDieFaces
                  ? null
                  : () => onChange(design.removedFace(current)),
            ),
          ],
        ),
      ],
    );
  }
}
