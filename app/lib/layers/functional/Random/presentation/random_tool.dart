import 'dart:math';

import 'package:flutter/material.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../domain/random_tools.dart';

class RandomTool extends StatefulWidget {
  const RandomTool({super.key, required this.id, required this.names});
  final String id;
  final List<String> names;
  @override
  State<RandomTool> createState() => _RandomToolState();
}

class _RandomToolState extends State<RandomTool>
    with SingleTickerProviderStateMixin {
  final random = RandomTools();
  late final TextEditingController options;
  final minimum = TextEditingController(text: '1'),
      maximum = TextEditingController(text: '100');
  late final AnimationController spin;
  Animation<double>? rotation;
  String result = '';
  int teamCount = 2, roleIndex = 0;
  bool revealed = false, hasDrawn = false;
  List<String> bag = [], roles = [];
  double angle = 0;
  List<String> wheelLabels = [];
  @override
  void initState() {
    super.initState();
    options = TextEditingController(
      text: widget.id == 'roles'
          ? List.generate(
              widget.names.length,
              (i) => i == 0 ? 'Loup' : 'Villageois',
            ).join(', ')
          : widget.id == 'bag'
          ? 'Rouge, Bleu, Vert, Rouge, Bleu'
          : widget.names.join(', '),
    );
    spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    spin.duration = Duration(
      milliseconds: MediaQuery.of(context).disableAnimations ? 1 : 1600,
    );
  }

  @override
  void dispose() {
    options.dispose();
    minimum.dispose();
    maximum.dispose();
    spin.dispose();
    super.dispose();
  }

  List<String> parse() => options.text
      .split(RegExp(r'[,\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  void fail(String message) => notify(context, message);
  void draw() {
    try {
      if (widget.id == 'teams') {
        if (widget.names.length < 2) {
          fail('Au moins deux joueurs sont nécessaires.');
          return;
        }
        final teams = random.teams(
          widget.names,
          teamCount.clamp(2, widget.names.length),
        );
        setState(
          () => result = teams.indexed
              .map((e) => 'ÉQUIPE ${e.$1 + 1}\n${e.$2.join(' · ')}')
              .join('\n\n'),
        );
      } else if (widget.id == 'order') {
        setState(
          () => result = random
              .shuffled(widget.names)
              .indexed
              .map((e) => '${e.$1 + 1}. ${e.$2}')
              .join('\n'),
        );
      } else if (widget.id == 'coin') {
        setState(() => result = random.integer(0, 1) == 0 ? 'PILE' : 'FACE');
      } else if (widget.id == 'number') {
        final low = int.tryParse(minimum.text),
            high = int.tryParse(maximum.text);
        if (low == null || high == null) {
          throw const FormatException('Saisissez deux nombres entiers.');
        }
        setState(() => result = '${random.integer(low, high)}');
      } else if (widget.id == 'bag') {
        if (!hasDrawn) {
          bag = random.shuffled(parse());
          hasDrawn = true;
        }
        if (bag.isEmpty) {
          fail('Le sac est vide. Remplissez-le pour recommencer.');
          return;
        }
        setState(() => result = bag.removeLast());
      } else if (widget.id == 'roles') {
        final pool = parse();
        if (pool.length != widget.names.length || pool.isEmpty) {
          throw const FormatException(
            'Prévoyez exactement un rôle par joueur.',
          );
        }
        setState(() {
          roles = random.shuffled(pool);
          roleIndex = 0;
          revealed = false;
          result = '';
        });
      } else if (widget.id == 'wheel') {
        final entries = parse();
        if (entries.length < 2 || entries.length > 50) {
          throw const FormatException('Choisissez entre 2 et 50 options.');
        }
        final labels = <String>[], weights = <int>[];
        for (final entry in entries) {
          final parts = entry.split(':');
          final weight = parts.length == 2
              ? int.tryParse(parts.last.trim())
              : 1;
          if (parts.length > 2 ||
              weight == null ||
              weight < 1 ||
              weight > 1000000) {
            throw const FormatException('Poids : un entier de 1 à 1 000 000.');
          }
          labels.add(parts.first.trim());
          weights.add(weight);
        }
        final index = random.weighted(
          List.generate(labels.length, (i) => i),
          weights,
        );
        final start = angle;
        angle +=
            pi * 8 +
            (2 * pi - angle % (2 * pi)) +
            (2 * pi - (index + .5) * 2 * pi / labels.length);
        setState(() {
          wheelLabels = labels;
          result = '';
          rotation = Tween<double>(
            begin: start,
            end: angle,
          ).animate(CurvedAnimation(parent: spin, curve: Curves.easeOutCubic));
        });
        spin.forward(from: 0).then((_) {
          if (mounted) setState(() => result = labels[index]);
        });
      }
    } on ArgumentError catch (e) {
      fail(e.message.toString());
    } on FormatException catch (e) {
      fail(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = switch (widget.id) {
      'teams' => tr(context, 'Faire les équipes', 'Create teams'),
      'order' => tr(context, 'Ordre de passage', 'Turn order'),
      'coin' => tr(context, 'Pile ou face', 'Heads or tails'),
      'number' => tr(context, 'Nombre aléatoire', 'Random number'),
      'bag' => tr(context, 'Sac de jetons', 'Token bag'),
      'roles' => tr(context, 'Rôles secrets', 'Secret roles'),
      _ => tr(context, 'Tourner la roue', 'Spin the wheel'),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 20),
        if (widget.id == 'teams')
          DropdownButtonFormField<int>(
            initialValue: teamCount.clamp(2, max(2, widget.names.length)),
            decoration: InputDecoration(
              labelText: tr(context, 'Nombre d’équipes', 'Number of teams'),
            ),
            items: List.generate(
              max(1, widget.names.length - 1),
              (i) => DropdownMenuItem(value: i + 2, child: Text('${i + 2}')),
            ),
            onChanged: (v) => setState(() => teamCount = v!),
          ),
        if (widget.id == 'number')
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: minimum,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Minimum'),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: maximum,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Maximum'),
                ),
              ),
            ],
          ),
        if (['bag', 'wheel', 'roles'].contains(widget.id))
          TextField(
            controller: options,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: widget.id == 'roles'
                  ? tr(
                      context,
                      'Un rôle par joueur, séparés par des virgules',
                      'One role per player, comma separated',
                    )
                  : tr(
                      context,
                      'Options séparées par des virgules',
                      'Comma-separated options',
                    ),
              helperText: widget.id == 'wheel'
                  ? tr(
                      context,
                      'Poids facultatif : Camille:2, Alex:1',
                      'Optional weights: Camille:2, Alex:1',
                    )
                  : widget.id == 'bag'
                  ? tr(
                      context,
                      'Les répétitions représentent plusieurs jetons.',
                      'Repeated entries represent several tokens.',
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {
              hasDrawn = false;
              roles = [];
              result = '';
            }),
          ),
        if (widget.id == 'wheel')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  DeckIcon(
                    Icons.arrow_drop_down,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  AnimatedBuilder(
                    animation: spin,
                    builder: (context, child) => Transform.rotate(
                      angle: rotation?.value ?? 0,
                      child: child,
                    ),
                    child: CustomPaint(
                      size: const Size(240, 240),
                      painter: WheelPainter(
                        wheelLabels.isEmpty ? parse() : wheelLabels,
                        theme.colorScheme.primary,
                        theme.colorScheme.surface,
                        theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      context,
                      'Les poids influencent le tirage, pas la taille des secteurs.',
                      'Weights affect the draw, not sector sizes.',
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        if (result.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Semantics(
              liveRegion: true,
              child: SelectableText(
                result,
                style: widget.id == 'teams' || widget.id == 'order'
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineLarge,
              ),
            ),
          ),
        if (widget.id == 'bag' && hasDrawn)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '${bag.length} ${tr(context, 'jetons restants', 'tokens remaining')}',
            ),
          ),
        if (widget.id == 'roles' && roles.isNotEmpty) ...[
          const SizedBox(height: 24),
          DeckRoleCard(
            name: widget.names[roleIndex],
            role: roles[roleIndex],
            revealed: revealed,
            onReveal: () => setState(() => revealed = true),
            onNext: () {
              if (roleIndex + 1 >= roles.length) {
                setState(() {
                  roles = [];
                  result = tr(
                    context,
                    'Tous les rôles ont été distribués.',
                    'All roles have been assigned.',
                  );
                });
              } else {
                setState(() {
                  revealed = false;
                  roleIndex++;
                });
              }
            },
          ),
          const SizedBox(height: 20),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: spin.isAnimating ? null : draw,
              child: Text(
                widget.id == 'roles'
                    ? tr(context, 'Distribuer les rôles', 'Assign roles')
                    : tr(context, 'Tirer au sort', 'Draw'),
              ),
            ),
            if (widget.id == 'bag')
              OutlinedButton(
                onPressed: () => setState(() {
                  bag = [];
                  hasDrawn = false;
                  result = '';
                }),
                child: Text(tr(context, 'Remplir le sac', 'Refill bag')),
              ),
          ],
        ),
        if (['teams', 'order'].contains(widget.id))
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              '${tr(context, 'Participants', 'Participants')} : ${widget.names.join(' · ')}',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
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
      border: Border.all(color: Theme.of(context).colorScheme.primary),
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
            role,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onNext,
            child: Text(
              tr(context, 'Masquer et passer au suivant', 'Hide and pass'),
            ),
          ),
        ] else
          FilledButton(
            onPressed: onReveal,
            child: Text(tr(context, 'Voir mon rôle', 'Reveal my role')),
          ),
      ],
    ),
  );
}

class WheelPainter extends CustomPainter {
  WheelPainter(this.labels, this.accent, this.background, this.ink);
  final List<String> labels;
  final Color accent, background, ink;
  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2),
        radius = size.width / 2,
        sweep = 2 * pi / labels.length;
    for (var i = 0; i < labels.length; i++) {
      final start = -pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        start,
        sweep,
        true,
        Paint()
          ..color = Color.lerp(background, accent, i.isEven ? 0.16 : 0.32)!,
      );
      canvas.drawLine(
        center,
        center + Offset(cos(start), sin(start)) * radius,
        Paint()..color = accent.withValues(alpha: .5),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(start + sweep / 2);
      final text = TextPainter(
        text: TextSpan(
          text: labels[i].length > 12
              ? '${labels[i].substring(0, 11)}…'
              : labels[i],
          style: TextStyle(
            color: ink,
            fontSize: labels.length > 12 ? 9 : 12,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * .7);
      text.paint(canvas, Offset(radius * .24, -text.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, 16, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.labels != labels || old.accent != accent;
}
