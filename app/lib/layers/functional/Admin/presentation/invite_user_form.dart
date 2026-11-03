import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class InviteUserForm extends StatefulWidget {
  const InviteUserForm({super.key, required this.busy});

  final bool busy;

  @override
  State<InviteUserForm> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<InviteUserForm> {
  final email = TextEditingController();
  final name = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final sent = await context.read<AdminCubit>().invite(email.text, name.text);
    if (!sent || !mounted) return;
    email.clear();
    name.clear();
  }

  @override
  Widget build(BuildContext context) => DeckPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr(
            context,
            'La personne reçoit un e-mail pour activer son compte.',
            'They get an email to activate their account.',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: tr(context, 'E-mail', 'Email'),
          ),
        ),
        TextField(
          controller: name,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: tr(context, 'Prénom (facultatif)', 'Name (optional)'),
          ),
          onSubmitted: (_) => _invite(),
        ),
        FilledButton.icon(
          onPressed: widget.busy ? null : _invite,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(tr(context, 'Inviter', 'Invite')),
        ),
      ],
    ),
  );
}
