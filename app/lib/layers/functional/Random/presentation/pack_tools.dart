import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_tool.dart';

class PackDiceTool extends StatefulWidget {
  const PackDiceTool({super.key, required this.pack});
  final GameTemplate pack;
  @override
  State<PackDiceTool> createState() => _PackDiceToolState();
}

class _PackDiceToolState extends State<PackDiceTool> {
  final random = RandomTools();
  final locked = <int>{};
  List<DieFace> results = [];
  final history = <String>[];
  List<GameDie> get pool => [
    for (final d in widget.pack.dice)
      for (var i = 0; i < d.count; i++) d,
  ];
  void roll() {
    final ds = pool;
    setState(() {
      results = [
        for (var i = 0; i < ds.length; i++)
          locked.contains(i) && i < results.length
              ? results[i]
              : ds[i].faces[random.integer(0, ds[i].faces.length - 1)],
      ];
      history.insert(0, results.map((f) => f.label).join(' · '));
      if (history.length > 10) history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.pack.name, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      for (final d in widget.pack.dice)
        Text('${d.count} × ${d.name} · ${d.faces.length} faces'),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < results.length; i++)
            FilterChip(
              selected: locked.contains(i),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(pool[i].name),
                  Text(
                    results[i].label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('${numberText(results[i].value)} points'),
                ],
              ),
              onSelected: (v) =>
                  setState(() => v ? locked.add(i) : locked.remove(i)),
            ),
        ],
      ),
      if (results.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'TOTAL / ${numberText(results.fold<double>(0, (n, f) => n + f.value))}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      FilledButton.icon(
        onPressed: roll,
        icon: const DeckIcon(Icons.casino_outlined),
        label: const Text('Lancer les dés du jeu'),
      ),
      const SizedBox(height: 12),
      const Text(
        'Touchez un dé pour le conserver au prochain lancer. Les faces répétées influencent les probabilités.',
      ),
      if (history.isNotEmpty) ...[
        const SectionHeading('Derniers lancers'),
        for (final h in history) Text(h),
      ],
    ],
  );
}

class PackRolesTool extends StatefulWidget {
  const PackRolesTool({super.key, required this.pack, required this.names});
  final GameTemplate pack;
  final List<String> names;
  @override
  State<PackRolesTool> createState() => _PackRolesToolState();
}

class _PackRolesToolState extends State<PackRolesTool>
    with WidgetsBindingObserver {
  List<GameRole> cards = [];
  int index = 0;
  bool revealed = false, done = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && revealed) {
      setState(() => revealed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.pack.roles.fold<int>(0, (n, r) => n + r.count),
        valid = count == widget.names.length && count > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôles · ${widget.pack.name}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text('$count cartes pour ${widget.names.length} joueurs'),
        const SizedBox(height: 12),
        if (cards.isEmpty)
          for (final r in widget.pack.roles) Text('${r.count} × ${r.name}'),
        if (!valid)
          const Text(
            'Adaptez les effectifs dans le builder ou créez une partie avec le bon nombre de joueurs.',
          ),
        if (cards.isNotEmpty) ...[
          const SizedBox(height: 24),
          DeckRoleCard(
            name: widget.names[index],
            role: '${cards[index].name}\n\n${cards[index].description}',
            revealed: revealed,
            onReveal: () => setState(() => revealed = true),
            onNext: () => setState(() {
              revealed = false;
              if (index + 1 == cards.length) {
                cards = [];
                done = true;
              } else {
                index++;
              }
            }),
          ),
        ],
        if (done)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Tous les rôles ont été distribués.'),
          ),
        if (cards.isEmpty) ...[
          const SizedBox(height: 20),
          FilledButton(
            onPressed: valid
                ? () => setState(() {
                    cards = RandomTools().shuffled([
                      for (final r in widget.pack.roles)
                        for (var i = 0; i < r.count; i++) r,
                    ]);
                    index = 0;
                    revealed = false;
                    done = false;
                  })
                : null,
            child: Text(
              done ? 'Redistribuer les rôles' : 'Distribuer les rôles',
            ),
          ),
        ],
      ],
    );
  }
}
