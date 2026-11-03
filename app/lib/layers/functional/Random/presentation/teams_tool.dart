import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/teams_finger_pad.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

const teamColors = [
  Color(0xffe4572e),
  Color(0xff3d7dd8),
  Color(0xff2e9e6b),
  Color(0xfff2b134),
  Color(0xff8e5bd8),
  Color(0xffd84f9e),
];

enum TeamSource { list, lobby, fingers }

class TeamsTool extends StatefulWidget {
  const TeamsTool({
    super.key,
    required this.names,
    this.lobbyNames = const [],
    this.haptics = true,
  });

  final List<String> names, lobbyNames;
  final bool haptics;

  @override
  State<TeamsTool> createState() => _TeamsToolState();
}

class _TeamsToolState extends State<TeamsTool> {
  final random = RandomTools();
  late final names = TextEditingController(text: widget.names.join(', '));
  late TeamSource source = widget.lobbyNames.length >= 2
      ? TeamSource.lobby
      : TeamSource.list;
  int teamCount = 2;
  List<List<String>> teams = [];

  @override
  void dispose() {
    names.dispose();
    super.dispose();
  }

  List<String> get players => source == TeamSource.lobby
      ? widget.lobbyNames
      : names.text
            .split(RegExp(r'[,\n]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

  void _draw() {
    final pool = players;
    if (pool.length < 2) {
      notify(
        context,
        tr(
          context,
          'Au moins deux joueurs sont nécessaires.',
          'At least two players are needed.',
        ),
      );
      return;
    }
    setState(() => teams = random.teams(pool, min(teamCount, pool.length)));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SegmentedButton<TeamSource>(
        segments: [
          ButtonSegment(
            value: TeamSource.list,
            icon: const Icon(Icons.edit_note),
            label: Text(tr(context, 'Noms', 'Names')),
          ),
          if (widget.lobbyNames.isNotEmpty)
            ButtonSegment(
              value: TeamSource.lobby,
              icon: const Icon(Icons.wifi_tethering),
              label: Text(tr(context, 'Salon', 'Lobby')),
            ),
          ButtonSegment(
            value: TeamSource.fingers,
            icon: const Icon(Icons.touch_app_outlined),
            label: Text(tr(context, 'Au doigt', 'Fingers')),
          ),
        ],
        selected: {source},
        onSelectionChanged: (v) => setState(() {
          source = v.first;
          teams = [];
        }),
      ),
      const SizedBox(height: 16),
      _TeamCount(
        value: teamCount,
        onChanged: (v) => setState(() {
          teamCount = v;
          teams = [];
        }),
      ),
      const SizedBox(height: 16),
      ..._sourceBody(),
    ],
  );

  List<Widget> _sourceBody() => switch (source) {
    TeamSource.fingers => [
      TeamsFingerPad(teamCount: teamCount, haptics: widget.haptics),
    ],
    TeamSource.lobby => [
      Text(
        tr(
          context,
          'Joueurs du salon : ${widget.lobbyNames.join(' · ')}',
          'Lobby players: ${widget.lobbyNames.join(' · ')}',
        ),
      ),
      ..._drawAndResult(),
    ],
    TeamSource.list => [
      TextField(
        controller: names,
        minLines: 2,
        maxLines: 6,
        decoration: InputDecoration(
          labelText: tr(
            context,
            'Prénoms, séparés par des virgules',
            'Names, comma separated',
          ),
        ),
        onChanged: (_) => setState(() => teams = []),
      ),
      ..._drawAndResult(),
    ],
  };

  List<Widget> _drawAndResult() => [
    const SizedBox(height: 16),
    Align(
      alignment: Alignment.centerLeft,
      child: FilledButton(
        onPressed: _draw,
        child: Text(tr(context, 'Former les équipes', 'Make teams')),
      ),
    ),
    if (teams.isNotEmpty) ...[
      const SizedBox(height: 20),
      Semantics(
        liveRegion: true,
        child: ResponsiveGrid(
          minimumWidth: 200,
          children: [
            for (final (index, team) in teams.indexed)
              _TeamCard(index: index, members: team),
          ],
        ),
      ),
    ],
  ];
}

class _TeamCount extends StatelessWidget {
  const _TeamCount({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(tr(context, 'Équipes', 'Teams')),
      const SizedBox(width: 12),
      IconButton(
        tooltip: tr(context, 'Une équipe de moins', 'One team less'),
        onPressed: value > 2 ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove),
      ),
      Text('$value', style: Theme.of(context).textTheme.titleLarge),
      IconButton(
        tooltip: tr(context, 'Une équipe de plus', 'One more team'),
        onPressed: value < teamColors.length
            ? () => onChanged(value + 1)
            : null,
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.index, required this.members});

  final int index;
  final List<String> members;

  @override
  Widget build(BuildContext context) => DeckPanel(
    padding: 16,
    color: teamColors[index].withValues(alpha: .18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: teamColors[index],
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tr(context, 'Équipe ${index + 1}', 'Team ${index + 1}'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final name in members) Text(name),
      ],
    ),
  );
}
