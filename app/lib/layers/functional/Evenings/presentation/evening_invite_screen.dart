import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_detail.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class EveningInviteScreen extends StatefulWidget {
  const EveningInviteScreen({super.key, required this.code});

  final String code;

  @override
  State<EveningInviteScreen> createState() => _EveningInviteScreenState();
}

class _EveningInviteScreenState extends State<EveningInviteScreen> {
  late final Future<Evening?> loading = context.read<EveningsCubit>().fetch(
    widget.code,
  );

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.eveningsInvitation,
    fallback: '/evenings',
    child: FutureBuilder<Evening?>(
      future: loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final cubit = context.watch<EveningsCubit>();
        final evening = snapshot.data == null
            ? null
            : cubit.evening(snapshot.data!.id) ?? snapshot.data;
        if (evening == null) {
          return EmptyPanel(
            title: context.l10n.eveningsNightNotFound,
            message: cubit.online
                ? context.l10n.eveningsCheckTheCodeWithThe
                : context.l10n.eveningsThisBuildHasNoServer,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              evening.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            EveningBody(evening: evening),
          ],
        );
      },
    ),
  );
}
