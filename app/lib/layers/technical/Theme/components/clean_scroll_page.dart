import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/large_title_header.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/layout_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class CleanScrollPage extends StatelessWidget {
  const CleanScrollPage({
    super.key,
    required this.title,
    required this.child,
    required this.onBack,
    this.actions = const [],
    this.maxWidth = 760,
    this.fillHeight = false,
    this.bottomBar,
  });
  final String title;
  final Widget child;
  final VoidCallback onBack;
  final List<Widget> actions;
  final double maxWidth;
  final bool fillHeight;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final inset = Gutters.columnInsetOf(context, maxWidth);
    final content = SizedBox(
      key: const ValueKey('screen-content'),
      width: double.infinity,
      child: child,
    );
    return Scaffold(
      bottomNavigationBar: bottomBar,
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
                  color: Theme.of(context).colorScheme.accentInk,
                  onPressed: onBack,
                ),
                actions: actions,
                inset: inset,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(inset, Space.sm, inset, Space.xl),
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
