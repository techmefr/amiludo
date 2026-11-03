import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_texts.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/technical/Qr/invite_card.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

Future<void> runEveningAction(
  BuildContext context,
  Future<Object?> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) notify(context, eveningErrorText(context, error));
  }
}

class EveningInvite extends StatelessWidget {
  const EveningInvite({super.key, required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EveningsCubit>();
    if (evening.published) {
      return InviteCard(
        link: RoomLink(RoomKind.evening, evening.code),
        title: evening.title,
      );
    }
    if (!cubit.online) {
      return EmptyPanel(
        title: tr(context, 'Mode local', 'Local mode'),
        message: tr(
          context,
          'Sans serveur, notez vous-même les réponses de vos amis ci-dessous.',
          'Without a server, record your friends’ answers yourself below.',
        ),
      );
    }
    return EmptyPanel(
      title: tr(context, 'Inviter en ligne', 'Invite online'),
      message: tr(
        context,
        'Publiez la soirée : vos amis s’inscrivent avec le lien, le code ou le QR.',
        'Publish the night: friends sign up with the link, code or QR.',
      ),
      action: cubit.signedIn
          ? FilledButton.icon(
              onPressed: () =>
                  runEveningAction(context, () => cubit.publish(evening)),
              icon: const Icon(Icons.public),
              label: Text(tr(context, 'Publier', 'Publish')),
            )
          : OutlinedButton(
              onPressed: () => context.go('/account'),
              child: Text(
                tr(context, 'Se connecter pour publier', 'Sign in to publish'),
              ),
            ),
    );
  }
}

class FriendAnswers extends StatelessWidget {
  const FriendAnswers({super.key, required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<EveningsCubit>();
    final friends = cubit.state.friends;
    if (friends.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(tr(context, 'Réponses de vos amis', 'Friends’ answers')),
        for (final friend in friends)
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(friend.color)),
            title: Text(friend.name),
            subtitle: Text(switch (evening
                .rsvpOf('friend:${friend.id}')
                ?.answer) {
              final answer? => answerLabel(context, answer),
              null => tr(context, 'Sans réponse', 'No answer'),
            }),
            trailing: PopupMenuButton<RsvpAnswer>(
              tooltip: tr(
                context,
                'Réponse de ${friend.name}',
                '${friend.name}’s answer',
              ),
              onSelected: (answer) => runEveningAction(
                context,
                () => cubit.answer(
                  evening.id,
                  answer,
                  guestId: 'friend:${friend.id}',
                  guestName: friend.name,
                ),
              ),
              itemBuilder: (context) => [
                for (final answer in RsvpAnswer.values)
                  PopupMenuItem(
                    value: answer,
                    child: Text(answerLabel(context, answer)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
