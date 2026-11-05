import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/presentation/admin_texts.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

enum _UserAction { admin, block, remove }

class ManagedUserTile extends StatelessWidget {
  const ManagedUserTile({super.key, required this.user, required this.busy});

  final ManagedUser user;
  final bool busy;

  Future<void> _run(BuildContext context, _UserAction action) async {
    final cubit = context.read<AdminCubit>();
    switch (action) {
      case _UserAction.admin:
        await cubit.toggleAdmin(user);
      case _UserAction.block:
        await cubit.toggleBlocked(user);
      case _UserAction.remove:
        final sure = await confirm(
          context,
          context.l10n.adminDelete(user.label),
          context.l10n.adminTheAccountAndItsPublished,
        );
        if (sure) await cubit.remove(user);
    }
  }

  List<Widget> _chips(BuildContext context) => [
    if (user.admin) Chip(label: Text(context.l10n.accountAdmin)),
    if (user.blocked) Chip(label: Text(context.l10n.adminBlocked)),
    if (!user.confirmed) Chip(label: Text(context.l10n.adminPending)),
  ];

  @override
  Widget build(BuildContext context) => DeckPanel(
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(user.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.name.isNotEmpty) Text(user.email),
          Text(lastSeenText(context, user)),
          Wrap(spacing: 6, runSpacing: 6, children: _chips(context)),
        ],
      ),
      trailing: PopupMenuButton<_UserAction>(
        enabled: !busy,
        tooltip: context.l10n.adminAccountActions,
        onSelected: (action) => _run(context, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _UserAction.admin,
            child: Text(
              user.admin
                  ? context.l10n.adminRemoveAdminRole
                  : context.l10n.adminMakeAdmin,
            ),
          ),
          PopupMenuItem(
            value: _UserAction.block,
            child: Text(
              user.blocked
                  ? context.l10n.adminUnblock
                  : context.l10n.adminBlock,
            ),
          ),
          PopupMenuItem(
            value: _UserAction.remove,
            child: Text(context.l10n.randomDelete),
          ),
        ],
      ),
    ),
  );
}
