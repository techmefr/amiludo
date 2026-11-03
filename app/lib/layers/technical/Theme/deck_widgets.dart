export 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

class DeckPanel extends StatelessWidget {
  const DeckPanel({
    super.key,
    required this.child,
    this.padding = 24,
    this.highlight = false,
    this.color,
  });
  final Widget child;
  final double padding;
  final bool highlight;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), style = theme.extension<DeckStyle>()!;
    return Material(
      color: color ?? theme.colorScheme.surface,
      shape: style.border(
        highlight ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(style.compact ? padding * .8 : padding),
        child: child,
      ),
    );
  }
}

class DeckHeading extends StatelessWidget {
  const DeckHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle = '',
    this.action,
  });
  final String eyebrow, title, subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: LayoutBuilder(
        builder: (context, c) => Wrap(
          spacing: 24,
          runSpacing: 20,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            SizedBox(
              width: c.maxWidth > 650 ? c.maxWidth - 240 : c.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow
                        .replaceAll(RegExp(r'^\d+ / '), '')
                        .replaceAll(' / ', ' · '),
                    style: TextStyle(
                      fontFamily: styleHeadingFont(context),
                      fontSize: 12,
                      letterSpacing: .2,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: theme.textTheme.headlineLarge),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: .72,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key, this.action});
  final String text;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?action,
      ],
    ),
  );
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minimumWidth = 220,
    this.gap = 16,
  });
  final List<Widget> children;
  final double minimumWidth, gap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final columns = ((c.maxWidth + gap) / (minimumWidth + gap)).floor().clamp(
        1,
        6,
      );
      final width = (c.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: children
            .map((w) => SizedBox(width: width, child: w))
            .toList(),
      );
    },
  );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => DeckPanel(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            DeckIcon(
              Icons.table_restaurant_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    ),
  );
}

String tr(BuildContext context, String french, String english) =>
    Localizations.localeOf(context).languageCode == 'en' ? english : french;
void notify(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
Future<bool> confirm(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr(context, 'Annuler', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr(context, 'Confirmer', 'Confirm')),
          ),
        ],
      ),
    ) ??
    false;

Future<T?> showFormDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final route = DialogRoute<T>(context: context, builder: builder);
  final result = await Navigator.of(context, rootNavigator: true).push(route);
  await route.completed;
  return result;
}

String styleHeadingFont(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium?.fontFamily ?? 'LilGrotesk';
