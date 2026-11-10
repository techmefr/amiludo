import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/use_cases/card_pack_use_cases.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/card_packs_page.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/cubit/card_pack_cubit.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/save_character_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/gateways/pack_catalog_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';

Future<List<GameTemplate>> _characterTemplates() async {
  final installed = getIt<ReadWorkspaceUseCase>()().templates;
  final bundled = await getIt<PackCatalogGateway>().bundled();
  final unique = <String, GameTemplate>{};
  for (final t in [...installed, ...bundled]) {
    if (t.creation.isNotEmpty) unique.putIfAbsent(t.id, () => t);
  }
  return unique.values.toList();
}

class CardPacksRoute extends StatefulWidget {
  const CardPacksRoute({super.key});

  @override
  State<CardPacksRoute> createState() => _CardPacksRouteState();
}

class _CardPacksRouteState extends State<CardPacksRoute> {
  late final Future<List<GameTemplate>> templates = _characterTemplates();

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CardPackCubit(
      getIt<ReadCardPackSessionUseCase>(),
      getIt<SaveCardPackSessionUseCase>(),
    ),
    child: FutureBuilder<List<GameTemplate>>(
      future: templates,
      builder: (context, snapshot) => CardPacksPage(
        templates: snapshot.data ?? const [],
        onSave: getIt<SaveCharacterUseCase>().call,
      ),
    ),
  );
}
