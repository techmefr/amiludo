import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';

class RolesTool extends StatefulWidget {
  const RolesTool({super.key, required this.names});
  final List<String> names;
  @override
  State<RolesTool> createState() => _RolesToolState();
}

class _RolesToolState extends State<RolesTool> {
  final random = RandomTools();
  TextEditingController? options;
  List<String> roles = [];
  int roleIndex = 0;
  bool revealed = false;
  String result = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    options ??= TextEditingController(
      text: starterRoles(
        widget.names.length,
        tr(context, 'Loup', 'Werewolf'),
        tr(context, 'Villageois', 'Villager'),
      ).join(', '),
    );
  }

  @override
  void dispose() {
    options?.dispose();
    super.dispose();
  }

  void draw() {
    try {
      final pool = parseRoles(options!.text, widget.names.length);
      setState(() {
        roles = random.shuffled(pool);
        roleIndex = 0;
        revealed = false;
        result = '';
      });
    } on RandomInputError catch (error) {
      notify(context, randomInputErrorText(context, error));
    }
  }

  void next() => setState(() {
    if (roleIndex + 1 >= roles.length) {
      roles = [];
      result = tr(
        context,
        'Tous les rôles ont été distribués.',
        'All roles have been assigned.',
      );
    } else {
      revealed = false;
      roleIndex++;
    }
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RandomOptionsField(
        controller: options!,
        label: tr(
          context,
          'Un rôle par joueur, séparés par des virgules',
          'One role per player, comma separated',
        ),
        onChanged: () => setState(() {
          roles = [];
          result = '';
        }),
      ),
      RandomResultSlot(text: result),
      if (roles.isNotEmpty) ...[
        const SizedBox(height: 24),
        DeckRoleCard(
          name: widget.names[roleIndex],
          role: roles[roleIndex],
          revealed: revealed,
          onReveal: () => setState(() => revealed = true),
          onNext: next,
        ),
        const SizedBox(height: 20),
      ],
      RandomDrawButton(
        onPressed: draw,
        label: tr(context, 'Distribuer les rôles', 'Assign roles'),
      ),
    ],
  );
}

class DeckRoleCard extends StatelessWidget {
  const DeckRoleCard({
    super.key,
    required this.name,
    required this.role,
    required this.revealed,
    required this.onReveal,
    required this.onNext,
  });
  final String name, role;
  final bool revealed;
  final VoidCallback onReveal, onNext;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Column(
      children: [
        Text(
          '${tr(context, 'Passez le téléphone à', 'Pass the device to')} $name',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (revealed) ...[
          Text(
            role.split('\n\n').first,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (role.contains('\n\n'))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                role.split('\n\n').skip(1).join('\n\n'),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onNext,
            child: Text(
              tr(context, 'Masquer et passer au suivant', 'Hide and pass'),
            ),
          ),
        ] else ...[
          const GameArt(tool: 'roles', height: 140),
          FilledButton(
            onPressed: onReveal,
            child: Text(tr(context, 'Voir mon rôle', 'Reveal my role')),
          ),
        ],
      ],
    ),
  );
}
