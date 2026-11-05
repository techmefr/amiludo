export 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
                        .replaceAll(' / ', ' · ')
                        .toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: theme.textTheme.headlineLarge),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: .78,
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
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: Theme.of(context).textTheme.headlineSmall),
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
      final textScale = (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
        1.0,
        1.8,
      );
      final columns = ((c.maxWidth + gap) / (minimumWidth * textScale + gap))
          .floor()
          .clamp(1, 6);
      final width = (c.maxWidth - gap * (columns - 1)) / columns;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: gap,
        children: [
          for (var start = 0; start < children.length; start += columns)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: gap,
                children: [
                  for (final child in children.skip(start).take(columns))
                    SizedBox(width: width, child: child),
                ],
              ),
            ),
        ],
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
    this.icon = Icons.table_restaurant_outlined,
  });
  final String title, message;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => DeckPanel(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            DeckIcon(
              icon,
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
    Localizations.localeOf(context).languageCode == 'fr' ? french : english;
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
            child: Text(context.l10n.themeCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.themeConfirm),
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
