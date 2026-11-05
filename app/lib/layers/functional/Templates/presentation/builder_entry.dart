import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_builder.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class BuilderEntry extends StatelessWidget {
  const BuilderEntry({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final ws = context.watch<TemplatesCubit>().state;
    final p = [
      ...ws.templates,
      ...GameTemplate.builtIn,
    ].where((p) => p.id == id).firstOrNull;
    if (p == null) {
      return FullPage(
        title: context.l10n.templatesPackNotFound,
        fallback: '/templates',
        child: Text(
          context.l10n.templatesThisPackIsNoLonger,
        ),
      );
    }
    final builtin = GameTemplate.builtIn.any((t) => t.id == id);
    return PackBuilder(
      template: builtin
          ? GameTemplate.fromJson({
              ...p.toJson(),
              'id': 'custom-${DateTime.now().microsecondsSinceEpoch}',
              'name': '${p.name} (${context.l10n.templatesCopy})',
            })
          : p,
    );
  }
}
