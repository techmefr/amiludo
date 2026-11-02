import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Theme/deck_icons.dart';
import '../../../technical/Theme/deck_theme.dart';
import '../../Game/domain/game.dart';
import '../../Random/domain/tool_catalog.dart';
import '../workspace_controller.dart';
import 'game_setup.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider).requireValue,
        theme = Theme.of(context),
        current = ws.current;
    final finished = ws.games
        .where((g) => g.finishedAt != null)
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(
            context,
            'Jouez ensemble / restez dans la partie',
            'Play together / stay in the game',
          ),
          title: tr(
            context,
            'On joue à quoi, aujourd’hui ?',
            'What are we playing today?',
          ),
          subtitle: tr(
            context,
            'Les bons outils. La bonne compagnie. Vos vraies parties.',
            'The right tools. Good company. Your actual games.',
          ),
          action: OutlinedButton.icon(
            onPressed: () => showNewGame(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: Text(tr(context, 'Nouvelle partie', 'New game')),
          ),
        ),
        DeckPanel(
          color: theme.colorScheme.surfaceContainerHighest,
          child: LayoutBuilder(
            builder: (context, c) => Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(
                          context,
                          'VOTRE PROCHAINE PARTIE COMMENCE ICI',
                          'YOUR NEXT GAME STARTS HERE',
                        ),
                        style: const TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tr(
                          context,
                          'LA TABLE EST PRÊTE.\nÀ VOUS DE JOUER.',
                          'THE TABLE IS READY.\nYOUR MOVE.',
                        ),
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr(
                          context,
                          'Scores, hasard et tempo :\ngardez l’esprit dans la partie.',
                          'Scores, chance and timing:\nkeep your mind in the game.',
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.go('/tools'),
                        icon: const Icon(Icons.arrow_outward, size: 18),
                        label: Text(
                          tr(context, 'Explorer les outils', 'Explore tools'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (c.maxWidth > 650)
                  SizedBox(
                    width: 260,
                    height: 220,
                    child: CustomPaint(
                      painter: DiePainter(
                        theme.colorScheme.primary,
                        theme.extension<DeckStyle>()!.signal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (current != null && current.finishedAt == null) ...[
          SectionHeading(
            tr(context, 'La partie continue', 'Your game continues'),
            action: TextButton(
              onPressed: () => context.go('/game'),
              child: const Text('→'),
            ),
          ),
          DeckPanel(
            highlight: true,
            child: Wrap(
              spacing: 24,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(current.title, style: theme.textTheme.titleLarge),
                    Text(
                      '${current.players.length} joueurs · Manche ${current.round} · ${current.players[current.activeIndex].name}',
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () => context.go('/game'),
                  child: Text(
                    tr(context, 'Reprendre la partie', 'Resume game'),
                  ),
                ),
              ],
            ),
          ),
        ],
        SectionHeading(
          tr(context, 'Les outils de la table', 'Tools for your table'),
          action: TextButton(
            onPressed: () => context.go('/tools'),
            child: Text(tr(context, 'Tout voir ↗', 'View all ↗')),
          ),
        ),
        ResponsiveGrid(
          minimumWidth: MediaQuery.sizeOf(context).width < 760 ? 150 : 280,
          children: toolDefinitions
              .where((t) => ws.favorites.contains(t.id))
              .map(
                (t) => DeckPanel(
                  padding: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(toolIcon(t.id), color: theme.colorScheme.primary),
                      const SizedBox(height: 20),
                      Text(
                        t.title.toUpperCase(),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(t.subtitle),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.push('/tools/${t.id}'),
                        child: Text(tr(context, 'Ouvrir ↗', 'Open ↗')),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        SectionHeading(
          tr(context, 'Vos derniers bons moments', 'Recent good times'),
          action: TextButton(
            onPressed: () => context.go('/history'),
            child: Text(tr(context, 'Historique ↗', 'History ↗')),
          ),
        ),
        if (finished.isEmpty)
          EmptyPanel(
            title: tr(
              context,
              'La première partie vous attend',
              'Your first game awaits',
            ),
            message: tr(
              context,
              'Vos résultats apparaîtront ici. Aucune partie fictive.',
              'Your real results will appear here.',
            ),
          ),
        for (final g in finished)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DeckPanel(
              padding: 20,
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.title, style: theme.textTheme.titleMedium),
                        Text(
                          '${g.winners.map((p) => p.name).join(' & ')} · ${numberText(g.score(g.winners.first.id))} pts',
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: const Text('↗'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DiePainter extends CustomPainter {
  DiePainter(this.accent, this.signal);
  final Color accent, signal;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2),
        radius = size.height * .42;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = accent;
    final vertices = List.generate(
      6,
      (i) =>
          center +
          Offset(cos(-pi / 2 + i * pi / 3), sin(-pi / 2 + i * pi / 3)) * radius,
    );
    final path = Path()..addPolygon(vertices, true);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .98,
        height: radius * 1.4,
      ),
      Paint()
        ..color = accent.withValues(alpha: .2)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(path, paint);
    final a = Offset(center.dx - radius * .46, center.dy - 8),
        b = Offset(center.dx + radius * .46, center.dy - 8);
    for (final (from, to) in [
      (vertices[0], a),
      (vertices[0], b),
      (vertices[2], b),
      (vertices[3], a),
      (vertices[3], b),
      (vertices[4], a),
      (a, b),
      (vertices[1], b),
      (vertices[5], a),
    ]) {
      canvas.drawLine(from, to, paint);
    }
    final text = TextPainter(
      text: TextSpan(
        text: '20',
        style: TextStyle(
          color: accent,
          fontSize: 40,
          fontFamily: 'ChakraPetch',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
    canvas.drawCircle(Offset(16, size.height * .7), 5, Paint()..color = signal);
  }

  @override
  bool shouldRepaint(DiePainter old) =>
      old.accent != accent || old.signal != signal;
}
