import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/presentation/account_form.dart';
import 'package:amiludo/layers/functional/Account/presentation/account_texts.dart';
import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/functional/Account/presentation/signed_in_panel.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _notice(BuildContext context, AccountNotice notice) =>
      switch (notice) {
        AccountNotice.saved => tr(context, 'Prénom enregistré', 'Name saved'),
        AccountNotice.checkMail => tr(
          context,
          'Compte créé : confirmez via l’e-mail reçu.',
          'Account created: confirm with the email you received.',
        ),
        AccountNotice.signedIn => tr(context, 'Connecté', 'Signed in'),
        AccountNotice.signedOut => tr(context, 'Déconnecté', 'Signed out'),
        AccountNotice.resetSent => tr(
          context,
          'E-mail de réinitialisation envoyé.',
          'Reset email sent.',
        ),
        AccountNotice.linkSent => tr(
          context,
          'Lien de connexion envoyé : regardez vos e-mails.',
          'Sign-in link sent: check your email.',
        ),
        AccountNotice.passwordChanged => tr(
          context,
          'Mot de passe modifié',
          'Password changed',
        ),
      };

  @override
  Widget build(BuildContext context) => FullPage(
    title: tr(context, 'Mon profil', 'My profile'),
    fallback: '/',
    child: BlocConsumer<AccountCubit, AccountState>(
      listenWhen: (a, b) => b.notice != null || b.error != null,
      listener: (context, state) => notify(
        context,
        state.error == null
            ? _notice(context, state.notice!)
            : accountErrorText(context, state.error!),
      ),
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Nickname(nickname: state.nickname),
          SectionHeading(tr(context, 'Compte en ligne', 'Online account')),
          if (!state.available)
            EmptyPanel(
              title: tr(context, 'Mode local', 'Local mode'),
              message: tr(
                context,
                'Cette version n’a pas de serveur : tout reste sur l’appareil. Les salons Wi-Fi marchent sans compte.',
                'This build has no server: everything stays on the device. Wi-Fi lobbies work without an account.',
              ),
            )
          else if (state.account != null)
            SignedInPanel(account: state.account!, busy: state.busy)
          else
            AccountForm(busy: state.busy, nickname: state.nickname),
        ],
      ),
    ),
  );
}

class _Nickname extends StatefulWidget {
  const _Nickname({required this.nickname});

  final String nickname;

  @override
  State<_Nickname> createState() => _NicknameState();
}

class _NicknameState extends State<_Nickname> {
  late final name = TextEditingController(text: widget.nickname);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        tr(
          context,
          'Le prénom que voient vos amis quand vous rejoignez une partie.',
          'The name friends see when you join a game.',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: name,
        maxLength: 40,
        autofillHints: const [AutofillHints.givenName],
        decoration: InputDecoration(
          labelText: tr(context, 'Votre prénom', 'Your name'),
        ),
      ),
      FilledButton(
        onPressed: () => context.read<AccountCubit>().saveNickname(name.text),
        child: Text(tr(context, 'Enregistrer', 'Save')),
      ),
    ],
  );
}
