import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Account/presentation/account_form.dart';
import 'package:amiludo/layers/functional/Account/presentation/account_texts.dart';
import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/functional/Account/presentation/signed_in_panel.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _notice(BuildContext context, AccountNotice notice) =>
      switch (notice) {
        AccountNotice.saved => context.l10n.accountNameSaved,
        AccountNotice.checkMail =>
          context.l10n.accountAccountCreatedConfirmWithThe,
        AccountNotice.signedIn => context.l10n.accountSignedIn,
        AccountNotice.signedOut => context.l10n.accountSignedOut,
        AccountNotice.resetSent => context.l10n.accountResetEmailSent,
        AccountNotice.linkSent => context.l10n.accountSignInLinkSentCheck,
        AccountNotice.passwordChanged => context.l10n.accountPasswordChanged,
      };

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.workspaceMyProfile,
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
          SectionHeading(context.l10n.accountOnlineAccount),
          if (!state.available)
            EmptyPanel(
              icon: Icons.cloud_off_outlined,
              title: context.l10n.accountLocalMode,
              message: context.l10n.accountThisBuildHasNoServer,
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
      Text(context.l10n.accountTheNameFriendsSeeWhen),
      const SizedBox(height: 12),
      TextField(
        controller: name,
        maxLength: 40,
        autofillHints: const [AutofillHints.givenName],
        decoration: InputDecoration(labelText: context.l10n.accountYourName),
      ),
      FilledButton(
        onPressed: () => context.read<AccountCubit>().saveNickname(name.text),
        child: Text(context.l10n.themeSave),
      ),
    ],
  );
}
