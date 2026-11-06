import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_discover.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_edition_step.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_recap.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_sheet_view.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_universe_picker.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/table_gestures.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class ChroniclesPage extends StatelessWidget {
  const ChroniclesPage({
    super.key,
    this.onSave,
    this.sound = false,
    this.haptics = false,
  });
  final bool sound, haptics;
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.chroniclesTitle,
    immersive: true,
    child: ChroniclesSettings(
      sound: sound,
      haptics: haptics,
      child: ChroniclesView(onSave: onSave),
    ),
  );
}

class ChroniclesView extends StatelessWidget {
  const ChroniclesView({super.key, this.onSave});
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChroniclesCubit, ChroniclesState>(
        builder: (context, state) {
          final data = state.data, run = state.run;
          if (state.failed) return Text(context.l10n.chroniclesLoadFailed);
          if (data == null) return const SizedBox.shrink();
          if (run == null) return ChroniclesUniversePicker(data: data);
          return switch (run.phase) {
            ChroniclesPhase.edition => ChroniclesEditionStep(
              data: data,
              run: run,
            ),
            ChroniclesPhase.discover => ChroniclesDiscover(
              key: ValueKey('${run.stepIndex}-${run.position}'),
              data: data,
              run: run,
              refusal: state.refusal,
            ),
            ChroniclesPhase.recap => ChroniclesRecap(data: data, run: run),
            ChroniclesPhase.done => ChroniclesSheetView(
              data: data,
              run: run,
              onSave: onSave,
            ),
          };
        },
      );
}
