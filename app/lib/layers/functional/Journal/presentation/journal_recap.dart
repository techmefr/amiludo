import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

String recapText(LogSession session, String locale) {
  final day = DateFormat.yMMMMd(locale).format(session.start.toLocal());
  final hour = DateFormat.Hm(locale);
  return [
    day,
    for (final e in session.entries)
      '${hour.format(e.at.toLocal())}  ${e.text}',
  ].join('\n');
}

Future<void> showJournalRecap(BuildContext context, GameLog log) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => JournalRecap(log: log),
    );

class JournalRecap extends StatefulWidget {
  const JournalRecap({super.key, required this.log});
  final GameLog log;

  @override
  State<JournalRecap> createState() => _JournalRecapState();
}

class _JournalRecapState extends State<JournalRecap> {
  int picked = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final sessions = widget.log.sessions();
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Text(l.journalRecapEmpty),
      );
    }
    final session = sessions[picked.clamp(0, sessions.length - 1)];
    final text = recapText(session, locale);
    return Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.journalRecapTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Space.md),
          SizedBox(
            height: Targets.minimum,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (i, s) in sessions.indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.sm),
                    child: ChoiceChip(
                      label: Text(
                        DateFormat.MMMd(locale).format(s.start.toLocal()),
                      ),
                      selected: i == picked,
                      onSelected: (_) => setState(() => picked = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          Flexible(child: SingleChildScrollView(child: SelectableText(text))),
          const SizedBox(height: Space.md),
          FilledButton.icon(
            onPressed: () async {
              final done = l.journalRecapCopied;
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.maybeOf(context)
                  ?.showSnackBar(SnackBar(content: Text(done)));
            },
            icon: const Icon(Icons.copy),
            label: Text(l.journalRecapCopy),
          ),
        ],
      ),
    );
  }
}
