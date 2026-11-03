import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({super.key, required this.busy, required this.nickname});

  final bool busy;
  final String nickname;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final email = TextEditingController();
  final password = TextEditingController();
  late final name = TextEditingController(text: widget.nickname);
  bool creating = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<AccountCubit>();
    if (creating) {
      cubit.signUp(email.text, password.text, name.text);
    } else {
      cubit.signIn(email.text, password.text);
    }
  }

  @override
  Widget build(BuildContext context) => AutofillGroup(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              label: Text(tr(context, 'Connexion', 'Sign in')),
            ),
            ButtonSegment(
              value: true,
              label: Text(tr(context, 'Inscription', 'Sign up')),
            ),
          ],
          selected: {creating},
          onSelectionChanged: (v) => setState(() => creating = v.first),
        ),
        const SizedBox(height: 16),
        if (creating)
          TextField(
            controller: name,
            maxLength: 40,
            autofillHints: const [AutofillHints.givenName],
            decoration: InputDecoration(
              labelText: tr(context, 'Prénom', 'Name'),
            ),
          ),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: tr(context, 'E-mail', 'Email'),
          ),
        ),
        TextField(
          controller: password,
          obscureText: true,
          autofillHints: [
            creating ? AutofillHints.newPassword : AutofillHints.password,
          ],
          decoration: InputDecoration(
            labelText: tr(context, 'Mot de passe', 'Password'),
            helperText: creating
                ? tr(context, '8 caractères minimum', 'At least 8 characters')
                : null,
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.busy ? null : _submit,
          child: Text(
            creating
                ? tr(context, 'Créer mon compte', 'Create my account')
                : tr(context, 'Se connecter', 'Sign in'),
          ),
        ),
        if (!creating)
          TextButton(
            onPressed: widget.busy
                ? null
                : () => context.read<AccountCubit>().resetPassword(email.text),
            child: Text(tr(context, 'Mot de passe oublié', 'Forgot password')),
          ),
      ],
    ),
  );
}
