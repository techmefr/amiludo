import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_detail.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

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
    title: tr(context, 'Invitation', 'Invitation'),
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
            title: tr(context, 'Soirée introuvable', 'Night not found'),
            message: cubit.online
                ? tr(
                    context,
                    'Vérifiez le code auprès de l’organisateur.',
                    'Check the code with the host.',
                  )
                : tr(
                    context,
                    'Cette version n’a pas de serveur pour retrouver les soirées.',
                    'This build has no server to look up nights.',
                  ),
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
