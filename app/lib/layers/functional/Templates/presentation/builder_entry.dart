import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_builder.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

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
        title: tr(context, 'Pack introuvable', 'Pack not found'),
        fallback: '/templates',
        child: Text(
          tr(
            context,
            'Ce pack n’est plus installé.',
            'This pack is no longer installed.',
          ),
        ),
      );
    }
    final builtin = GameTemplate.builtIn.any((t) => t.id == id);
    return PackBuilder(
      template: builtin
          ? GameTemplate.fromJson({
              ...p.toJson(),
              'id': 'custom-${DateTime.now().microsecondsSinceEpoch}',
              'name': '${p.name} (${tr(context, 'copie', 'copy')})',
            })
          : p,
    );
  }
}
