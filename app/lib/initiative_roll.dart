import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/dice_studio.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<int?> rollInitiativeIn3d(BuildContext context, String name) =>
    Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => InitiativeRollPage(name: name)),
    );

class InitiativeRollPage extends StatefulWidget {
  const InitiativeRollPage({super.key, required this.name});
  final String name;

  @override
  State<InitiativeRollPage> createState() => _InitiativeRollPageState();
}

class _InitiativeRollPageState extends State<InitiativeRollPage> {
  int? result;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final appearance = context.read<AppearanceCubit>().state.appearance;
    return Scaffold(
      appBar: AppBar(title: Text(l.combatRollTitle(widget.name))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: DieStudioHost(
                  child: DiceTrayPage(
                    initial: const DiceTraySettings(
                      dice: [DiceSpec(sides: 20)],
                    ),
                    solid: true,
                    haptics: appearance.haptics,
                    skin: appearance.dieSkin,
                    table: appearance.table,
                    onSettled: (total) => setState(() => result = total),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: SizedBox(
                width: double.infinity,
                height: Targets.minimum + Space.md,
                child: FilledButton(
                  onPressed: result == null
                      ? null
                      : () => Navigator.pop(context, result),
                  child: Text(l.combatUseRoll(result ?? 0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
