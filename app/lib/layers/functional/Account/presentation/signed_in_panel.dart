import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class SignedInPanel extends StatefulWidget {
  const SignedInPanel({super.key, required this.account, required this.busy});

  final Account account;
  final bool busy;

  @override
  State<SignedInPanel> createState() => _SignedInPanelState();
}

class _SignedInPanelState extends State<SignedInPanel> {
  final password = TextEditingController();

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  void _change() {
    context.read<AccountCubit>().changePassword(password.text);
    password.clear();
  }

  @override
  Widget build(BuildContext context) => DeckPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(widget.account.name),
          subtitle: Text(widget.account.email),
          trailing: widget.account.admin
              ? Chip(label: Text(context.l10n.accountAdmin))
              : null,
        ),
        TextField(
          controller: password,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: context.l10n.accountNewPassword,
            helperText: context.l10n.accountOptionalTheEmailLinkIs,
          ),
          onSubmitted: (_) => _change(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: widget.busy ? null : _change,
              child: Text(context.l10n.accountChangePassword),
            ),
            if (widget.account.admin)
              OutlinedButton.icon(
                onPressed: () => context.push('/admin'),
                icon: const Icon(Icons.manage_accounts_outlined),
                label: Text(context.l10n.accountManageAccounts),
              ),
            TextButton(
              onPressed: widget.busy
                  ? null
                  : context.read<AccountCubit>().signOut,
              child: Text(context.l10n.accountSignOut),
            ),
          ],
        ),
      ],
    ),
  );
}
