import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

Future<GeneratorTables> loadGeneratorTables(String language) async {
  try {
    return GeneratorTables.decode(
      await rootBundle.loadString('assets/generators/$language.json'),
    );
  } on FlutterError {
    return GeneratorTables.decode(
      await rootBundle.loadString('assets/generators/en.json'),
    );
  }
}

class GeneratorTool extends StatefulWidget {
  const GeneratorTool({super.key, required this.id});
  final String id;
  @override
  State<GeneratorTool> createState() => _GeneratorToolState();
}

class _GeneratorToolState extends State<GeneratorTool> {
  GeneratorEngine? engine;
  GeneratedSheet? sheet;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    loadGeneratorTables(language).then((tables) {
      if (!mounted) return;
      setState(() {
        engine = GeneratorEngine(tables);
        sheet = engine!.generate(widget.id);
      });
    });
  }

  void draw() => setState(() => sheet = engine!.generate(widget.id));

  Future<void> copy(GeneratedSheet s) async {
    await Clipboard.setData(ClipboardData(text: s.toText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.randomCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final s = sheet;
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s != null) ...[
          Semantics(
            liveRegion: true,
            child: SelectableText(s.title, style: theme.headlineMedium),
          ),
          const SizedBox(height: 16),
          for (final section in s.sections) ...[
            SectionHeading(section.label),
            for (final line in section.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SelectableText(line),
              ),
            const SizedBox(height: 12),
          ],
        ],
        RandomDrawButton(onPressed: engine == null ? null : draw),
        if (s != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => copy(s),
              icon: const DeckIcon(Icons.copy_outlined),
              label: Text(context.l10n.randomCopy),
            ),
          ),
      ],
    );
  }
}
