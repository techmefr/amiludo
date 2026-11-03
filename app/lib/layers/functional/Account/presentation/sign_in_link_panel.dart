import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class SignInLinkPanel extends StatefulWidget {
  const SignInLinkPanel({super.key, required this.busy, required this.email});

  final bool busy;
  final String Function() email;

  @override
  State<SignInLinkPanel> createState() => _SignInLinkPanelState();
}

class _SignInLinkPanelState extends State<SignInLinkPanel> {
  final code = TextEditingController();
  bool sent = false;

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  void _send() {
    context.read<AccountCubit>().sendSignInLink(widget.email());
    setState(() => sent = true);
  }

  void _verify() =>
      context.read<AccountCubit>().verifyCode(widget.email(), code.text);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: widget.busy ? null : _send,
        icon: const Icon(Icons.mark_email_unread_outlined),
        label: Text(
          tr(
            context,
            'Recevoir un lien de connexion',
            'Email me a sign-in link',
          ),
        ),
      ),
      if (sent) ...[
        const SizedBox(height: 12),
        Text(
          tr(
            context,
            'Ouvrez le lien reçu sur cet appareil, ou saisissez le code de l’e-mail.',
            'Open the link on this device, or type the code from the email.',
          ),
        ),
        TextField(
          controller: code,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          decoration: InputDecoration(
            labelText: tr(context, 'Code reçu', 'Code received'),
          ),
          onSubmitted: (_) => _verify(),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: widget.busy ? null : _verify,
          child: Text(tr(context, 'Valider le code', 'Confirm the code')),
        ),
      ],
    ],
  );
}
