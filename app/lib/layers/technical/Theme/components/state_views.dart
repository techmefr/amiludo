import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DeckLoadingState extends StatelessWidget {
  const DeckLoadingState({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: label,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Space.xl),
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

class DeckErrorState extends StatelessWidget {
  const DeckErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DeckIcon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: Space.lg),
            Semantics(
              liveRegion: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Space.xl),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(context.l10n.workspaceRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
