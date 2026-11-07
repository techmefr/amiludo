import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/large_title_header.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CleanScrollPage extends StatelessWidget {
  const CleanScrollPage({
    super.key,
    required this.title,
    required this.child,
    required this.onBack,
    this.actions = const [],
    this.maxWidth = 760,
    this.fillHeight = false,
  });
  final String title;
  final Widget child;
  final VoidCallback onBack;
  final List<Widget> actions;
  final double maxWidth;
  final bool fillHeight;

  static const double _side = Space.xl - Space.xs;

  @override
  Widget build(BuildContext context) {
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: LargeTitleHeader(
                title: title,
                top: MediaQuery.paddingOf(context).top,
                leading: BackButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: onBack,
                ),
                actions: actions,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(_side, Space.sm, _side, _side),
              sliver: fillHeight
                  ? SliverFillRemaining(hasScrollBody: false, child: content)
                  : SliverToBoxAdapter(child: content),
            ),
          ],
        ),
      ),
    );
  }
}
