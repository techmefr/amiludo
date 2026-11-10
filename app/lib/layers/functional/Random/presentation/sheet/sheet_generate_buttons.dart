import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/presentation/cubit/sheet_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/layout_tokens.dart';

List<Widget> sheetGenerateButtons(BuildContext context) {
  final l10n = context.l10n;
  final cubit = context.read<SheetCubit>();
  final style = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(Rows.minimum),
  );
  return [
    OutlinedButton(
      key: const ValueKey('sheet-generate-step'),
      style: style,
      onPressed: cubit.generateStep,
      child: Text(l10n.sheetGenerateStep),
    ),
    FilledButton(
      key: const ValueKey('sheet-generate-all'),
      style: style,
      onPressed: cubit.generateAll,
      child: Text(l10n.sheetGenerateAll),
    ),
  ];
}
