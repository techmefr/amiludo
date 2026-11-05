import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/presentation/admin_texts.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/functional/Admin/presentation/invite_user_form.dart';
import 'package:amiludo/layers/functional/Admin/presentation/managed_user_tile.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget _users(BuildContext context, AdminState state) =>
      switch (state.status) {
        AdminStatus.loading => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        AdminStatus.failed => EmptyPanel(
          title: context.l10n.adminListUnavailable,
          message: adminErrorText(
            context,
            state.error ?? AdminError.unreachable,
          ),
          action: FilledButton(
            onPressed: context.read<AdminCubit>().load,
            child: Text(context.l10n.workspaceRetry),
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
    title: context.l10n.adminAccounts,
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
          SectionHeading(context.l10n.adminInviteSomeone),
          InviteUserForm(busy: state.busy),
          SectionHeading(
            state.status == AdminStatus.ready
                ? context.l10n.adminAccounts2(state.users.length)
                : context.l10n.adminAccounts,
          ),
          _users(context, state),
        ],
      ),
    ),
  );
}
