import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double toolBackClearance = Space.xs + Targets.minimum + Space.lg;
const double toolPrimaryHeight = Targets.minimum + Space.md;

abstract final class ToolLayout {
  static double maxWidthFor(double width) =>
      Breakpoints.contentWidth(Breakpoints.classify(width));

  static double maxWidth(BuildContext context) =>
      maxWidthFor(MediaQuery.sizeOf(context).width);
}

class ToolBody extends StatelessWidget {
  const ToolBody({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ToolLayout.maxWidth(context)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.xl,
          toolBackClearance,
          Space.xl,
          Space.xl,
        ),
        child: child,
      ),
    ),
  );
}

class ToolPrimaryButton extends StatelessWidget {
  const ToolPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(toolPrimaryHeight),
    );
    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: SizedBox(
        width: double.infinity,
        child: icon == null
            ? FilledButton(
                style: style,
                onPressed: onPressed,
                child: Text(label),
              )
            : FilledButton.icon(
                style: style,
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              ),
      ),
    );
  }
}

class ToolResultText extends StatelessWidget {
  const ToolResultText({super.key, required this.text, this.compact = false});
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xl),
      child: Semantics(
        liveRegion: true,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SelectableText(
              text,
              textAlign: TextAlign.center,
              style: compact ? theme.headlineMedium : theme.displayLarge,
            ),
          ),
        ),
      ),
    );
  }
}
