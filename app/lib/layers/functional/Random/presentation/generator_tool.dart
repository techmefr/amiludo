import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/functional/Random/presentation/generator_card.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

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

  late final tool = toolThemeFor(widget.id);
  int drawn = 0;

  void draw() {
    tool.signal();
    setState(() {
      drawn++;
      sheet = engine!.generate(widget.id);
    });
  }

  Future<void> copy(GeneratedSheet s) async {
    await Clipboard.setData(ClipboardData(text: s.toText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.randomCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final s = sheet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s != null)
          AnimatedSwitcher(
            duration: Motion.of(context, Motion.slow),
            switchInCurve: tool.curve,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, .06),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: GeneratorCard(key: ValueKey(drawn), id: widget.id, sheet: s),
          ),
        const SizedBox(height: Space.lg),
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
