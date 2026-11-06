import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue_loader.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/hero.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/power.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/team.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_creator_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_avatar.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class HeroesTool extends StatefulWidget {
  const HeroesTool({super.key, this.team, this.catalogue});
  final TeamState? team;
  final AvatarCatalogue? catalogue;

  @override
  State<HeroesTool> createState() => _HeroesToolState();
}

class _HeroesToolState extends State<HeroesTool> {
  late final TeamState team = widget.team ?? TeamState(const TeamSettings());
  AvatarCatalogue? catalogue;

  @override
  void initState() {
    super.initState();
    catalogue = widget.catalogue;
    if (catalogue == null) {
      loadAvatarCatalogue().then((c) {
        if (mounted) setState(() => catalogue = c);
      }).ignore();
    }
  }

  Future<void> editAvatar(HeroState hero, AvatarCatalogue loaded) async {
    final look = await Navigator.of(context).push<AvatarLook>(
      MaterialPageRoute(
        builder: (_) =>
            AvatarCreatorScreen(initial: hero.avatar, catalogue: loaded),
      ),
    );
    if (look != null) setState(() => hero.avatar = look);
  }

  Future<String?> ask(String label) => showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController();
      return AlertDialog(
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    },
  );

  Future<void> addHero() async {
    final name = (await ask(context.l10n.heroesHeroName))?.trim();
    if (name == null || name.isEmpty) return;
    final color = heroPalette[team.heroes.length % heroPalette.length];
    setState(
      () => team.add(
        HeroSettings(
          name: name,
          color: color,
          counters: [
            CounterSettings(start: 10, minimum: 0, color: color, icon: 'heart'),
          ],
        ),
      ),
    );
  }

  Future<void> addPower(HeroState hero) async {
    final name = (await ask(context.l10n.heroesPowerName))?.trim();
    if (name == null || name.isEmpty) return;
    setState(() => hero.addPower(PowerSettings(name: name)));
  }

  @override
  Widget build(BuildContext context) {
    final active = team.active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (var i = 0; i < team.heroes.length; i++)
              ChoiceChip(
                label: Text(team.heroes[i].name),
                selected: i == team.activeIndex,
                tooltip: context.l10n.heroesMakeActive,
                onSelected: (_) => setState(() => team.setActive(i)),
              ),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(context.l10n.heroesAddHero),
              onPressed: addHero,
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        if (active == null)
          Text(context.l10n.heroesEmpty)
        else
          HeroView(
            key: ValueKey(active),
            state: active,
            onAddPower: () => addPower(active),
            avatar: catalogue == null || active.avatar.isEmpty
                ? null
                : HeroAvatar(look: active.avatar, catalogue: catalogue!),
            onEditAvatar: catalogue == null
                ? null
                : () => editAvatar(active, catalogue!),
          ),
      ],
    );
  }
}
