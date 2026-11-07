import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/hero.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_view.dart';
import 'package:amiludo/layers/functional/Companion/presentation/power_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class HeroView extends StatefulWidget {
  const HeroView({
    super.key,
    required this.state,
    this.onChanged,
    this.onAddPower,
    this.avatar,
    this.onEditAvatar,
  });
  final HeroState state;
  final VoidCallback? onChanged;
  final VoidCallback? onAddPower;
  final Widget? avatar;
  final VoidCallback? onEditAvatar;

  @override
  State<HeroView> createState() => _HeroViewState();
}

class _HeroViewState extends State<HeroView> {
  void changed() {
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.state;
    final background = Color(hero.color);
    final ink = readableOn(background);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.avatar != null)
              Center(child: SizedBox(height: 120, child: widget.avatar)),
            Text(
              hero.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: ink),
            ),
            for (final counter in hero.counters)
              CounterView(state: counter, onChanged: widget.onChanged),
            for (final power in hero.powers)
              PowerView(state: power, ink: ink, onChanged: changed),
            if (widget.onEditAvatar != null)
              TextButton.icon(
                onPressed: widget.onEditAvatar,
                style: TextButton.styleFrom(foregroundColor: ink),
                icon: const Icon(Icons.face),
                label: Text(context.l10n.avatarEdit),
              ),
            if (widget.onAddPower != null)
              TextButton.icon(
                onPressed: widget.onAddPower,
                style: TextButton.styleFrom(foregroundColor: ink),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.heroesAddPower),
              ),
          ],
        ),
      ),
    );
  }
}
