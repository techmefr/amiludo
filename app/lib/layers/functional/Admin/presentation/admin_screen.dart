import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/presentation/admin_texts.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/functional/Admin/presentation/invite_user_form.dart';
import 'package:amiludo/layers/functional/Admin/presentation/managed_user_tile.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget _users(BuildContext context, AdminState state) =>
      switch (state.status) {
        AdminStatus.loading => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        AdminStatus.failed => EmptyPanel(
          title: tr(context, 'Liste indisponible', 'List unavailable'),
          message: adminErrorText(
            context,
            state.error ?? AdminError.unreachable,
          ),
          action: FilledButton(
            onPressed: context.read<AdminCubit>().load,
            child: Text(tr(context, 'Réessayer', 'Retry')),
          ),
        ),
        AdminStatus.ready => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            for (final user in state.users)
              ManagedUserTile(user: user, busy: state.busy),
          ],
        ),
      };

  @override
  Widget build(BuildContext context) => FullPage(
    title: tr(context, 'Comptes', 'Accounts'),
    fallback: '/account',
    child: BlocConsumer<AdminCubit, AdminState>(
      listenWhen: (a, b) =>
          b.notice != null ||
          (b.error != null && b.status != AdminStatus.failed),
      listener: (context, state) => notify(
        context,
        state.error == null
            ? adminNoticeText(context, state.notice!)
            : adminErrorText(context, state.error!),
      ),
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(tr(context, 'Inviter quelqu’un', 'Invite someone')),
          InviteUserForm(busy: state.busy),
          SectionHeading(
            state.status == AdminStatus.ready
                ? tr(
                    context,
                    '${state.users.length} comptes',
                    '${state.users.length} accounts',
                  )
                : tr(context, 'Comptes', 'Accounts'),
          ),
          _users(context, state),
        ],
      ),
    ),
  );
}
