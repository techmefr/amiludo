import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_library_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_preview.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<DiceSpec?> pickLibraryDie(BuildContext context, DieStudioCubit cubit) =>
    showDeckSheet<DiceSpec>(
      context: context,
      title: context.l10n.diceMyDice,
      builder: (_) => DieStudio(
        cubit: cubit,
        child: DiePickerList(cubit: cubit),
      ),
    );

class DiePickerList extends StatelessWidget {
  const DiePickerList({super.key, required this.cubit});
  final DieStudioCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<DieStudioCubit, DieLibrary>(
      bloc: cubit,
      builder: (context, library) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (library.designs.isEmpty) Text(l.diceLibraryEmpty),
          Wrap(
            spacing: Space.md,
            runSpacing: Space.md,
            children: [
              for (final d in library.designs)
                Semantics(
                  button: true,
                  label: '${l.diceTrayAddDie} ${d.name}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.md),
                    onTap: () => Navigator.pop(context, DiceSpec.fromDesign(d)),
                    child: Padding(
                      padding: const EdgeInsets.all(Space.xs),
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            DiePreview(design: d, size: 64),
                            Text(d.name),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    DieStudio(cubit: cubit, child: const DieLibraryScreen()),
              ),
            ),
            child: Text(l.diceManage),
          ),
        ],
      ),
    );
  }
}
