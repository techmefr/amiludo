import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/presentation/admin_texts.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

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
          tr(context, 'Supprimer ${user.label} ?', 'Delete ${user.label}?'),
          tr(
            context,
            'Le compte et ses soirées publiées seront supprimés. C’est définitif.',
            'The account and its published nights will be deleted. This cannot be undone.',
          ),
        );
        if (sure) await cubit.remove(user);
    }
  }

  List<Widget> _chips(BuildContext context) => [
    if (user.admin) Chip(label: Text(tr(context, 'Admin', 'Admin'))),
    if (user.blocked) Chip(label: Text(tr(context, 'Bloqué', 'Blocked'))),
    if (!user.confirmed)
      Chip(label: Text(tr(context, 'En attente', 'Pending'))),
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
        tooltip: tr(context, 'Actions sur le compte', 'Account actions'),
        onSelected: (action) => _run(context, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _UserAction.admin,
            child: Text(
              user.admin
                  ? tr(context, 'Retirer le rôle admin', 'Remove admin role')
                  : tr(context, 'Rendre admin', 'Make admin'),
            ),
          ),
          PopupMenuItem(
            value: _UserAction.block,
            child: Text(
              user.blocked
                  ? tr(context, 'Débloquer', 'Unblock')
                  : tr(context, 'Bloquer', 'Block'),
            ),
          ),
          PopupMenuItem(
            value: _UserAction.remove,
            child: Text(tr(context, 'Supprimer', 'Delete')),
          ),
        ],
      ),
    ),
  );
}
