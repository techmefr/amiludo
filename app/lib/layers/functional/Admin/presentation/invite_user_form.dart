import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
          context.l10n.adminTheyGetAnEmailTo,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.l10n.accountEmail,
          ),
        ),
        TextField(
          controller: name,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: context.l10n.adminNameOptional,
          ),
          onSubmitted: (_) => _invite(),
        ),
        FilledButton.icon(
          onPressed: widget.busy ? null : _invite,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(context.l10n.adminInvite),
        ),
      ],
    ),
  );
}
