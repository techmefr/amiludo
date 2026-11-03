import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

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
              ? Chip(label: Text(tr(context, 'Admin', 'Admin')))
              : null,
        ),
        TextField(
          controller: password,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: tr(context, 'Nouveau mot de passe', 'New password'),
            helperText: tr(
              context,
              'Facultatif : le lien par e-mail suffit pour se connecter.',
              'Optional: the email link is enough to sign in.',
            ),
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
              child: Text(
                tr(context, 'Changer le mot de passe', 'Change password'),
              ),
            ),
            TextButton(
              onPressed: widget.busy
                  ? null
                  : context.read<AccountCubit>().signOut,
              child: Text(tr(context, 'Se déconnecter', 'Sign out')),
            ),
          ],
        ),
      ],
    ),
  );
}
