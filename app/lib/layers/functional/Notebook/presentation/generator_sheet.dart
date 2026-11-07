import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/generator_recipes.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

final notebookGeneratorIds = [
  'npc',
  'tavern',
  'encounter',
  'quest',
  'treasure',
  'villain',
  'town',
  ...generatorRecipes.keys,
];

Future<GeneratorTables> loadNotebookGenerators(
  AssetBundle bundle,
  String language,
) async {
  try {
    return GeneratorTables.decode(
      await bundle.loadString('assets/generators/$language.json'),
    );
  } on FlutterError {
    return GeneratorTables.decode(
      await bundle.loadString('assets/generators/en.json'),
    );
  }
}

Future<String?> showGeneratorSheet(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const GeneratorSheet(),
    );

class GeneratorSheet extends StatefulWidget {
  const GeneratorSheet({super.key, this.engineFor});
  final GeneratorEngine Function(GeneratorTables tables)? engineFor;

  @override
  State<GeneratorSheet> createState() => _GeneratorSheetState();
}

class _GeneratorSheetState extends State<GeneratorSheet> {
  GeneratorEngine? engine;
  String? chosen;
  GeneratedSheet? sheet;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    loadNotebookGenerators(DefaultAssetBundle.of(context), language).then((
      tables,
    ) {
      if (!mounted) return;
      setState(
        () =>
            engine = widget.engineFor?.call(tables) ?? GeneratorEngine(tables),
      );
    });
  }

  void draw(String id) => setState(() {
    chosen = id;
    sheet = engine!.generate(id);
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final s = sheet;
    return Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.notebookToolGenerator, style: theme.textTheme.titleLarge),
            const SizedBox(height: Space.md),
            if (engine != null)
              Wrap(
                spacing: Space.sm,
                children: [
                  for (final id in notebookGeneratorIds)
                    ChoiceChip(
                      label: Text(context.toolTitle(id)),
                      selected: chosen == id,
                      onSelected: (_) => draw(id),
                    ),
                ],
              ),
            if (s != null) ...[
              const SizedBox(height: Space.lg),
              Text(s.toText()),
              const SizedBox(height: Space.md),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => draw(chosen!),
                    child: Text(l.notebookReroll),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, s.toText()),
                      child: Text(l.notebookAddToJournal),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
