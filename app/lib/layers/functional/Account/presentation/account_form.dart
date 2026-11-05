import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/functional/Account/presentation/sign_in_link_panel.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
              label: Text(context.l10n.accountSignIn),
            ),
            ButtonSegment(
              value: true,
              label: Text(context.l10n.accountSignUp),
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
              labelText: context.l10n.accountName,
            ),
          ),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: context.l10n.accountEmail,
          ),
        ),
        TextField(
          controller: password,
          obscureText: true,
          autofillHints: [
            creating ? AutofillHints.newPassword : AutofillHints.password,
          ],
          decoration: InputDecoration(
            labelText: context.l10n.accountPassword,
            helperText: creating
                ? context.l10n.accountAtLeast8Characters
                : null,
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.busy ? null : _submit,
          child: Text(
            creating
                ? context.l10n.accountCreateMyAccount
                : context.l10n.accountSignIn2,
          ),
        ),
        if (!creating)
          TextButton(
            onPressed: widget.busy
                ? null
                : () => context.read<AccountCubit>().resetPassword(email.text),
            child: Text(context.l10n.accountForgotPassword),
          ),
        if (!creating)
          SignInLinkPanel(busy: widget.busy, email: () => email.text),
      ],
    ),
  );
}
