import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_look.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/portrait_painter.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_labels.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetReadView extends StatelessWidget {
  const SheetReadView({super.key, required this.sheet, required this.tables});
  final CharacterSheet sheet;
  final SheetTables tables;

  ChroniclesAppearance get _portrait {
    final look = SheetLook.of(sheet, tables);
    return ChroniclesAppearance(
      skin: look.colors['skin'],
      eyes: look.colors['eyes'],
      hair: look.hairless ? null : look.colors['hair'],
      build: sheet.first('build').toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: ChroniclesPortrait(look: _portrait)),
        Text(sheet.first('name'), style: theme.textTheme.headlineMedium),
        if (sheet.of('nickname').isNotEmpty)
          Text(
            '« ${sheet.first('nickname')} »',
            style: theme.textTheme.titleMedium,
          ),
        for (var step = 1; step <= SheetSpec.stepCount; step++) ...[
          SectionHeading(sheetStepLabel(l10n, step)),
          for (final field in SheetSpec.ofStep(step))
            if (sheet.of(field.id).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${sheetFieldLabel(l10n, field.id)} : ',
                        style: theme.textTheme.labelLarge,
                      ),
                      TextSpan(text: sheet.of(field.id).join(', ')),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }
}
