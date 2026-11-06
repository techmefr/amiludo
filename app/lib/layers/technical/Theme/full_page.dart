import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullPage extends StatelessWidget {
  const FullPage({
    super.key,
    required this.title,
    required this.child,
    this.fallback = '/tools',
    this.scroll = true,
    this.actions = const [],
    this.maxWidth = 760,
    this.fillHeight = false,
    this.immersive = false,
  });
  final String title, fallback;
  final Widget child;
  final bool scroll, fillHeight, immersive;
  final double maxWidth;
  final List<Widget> actions;

  static const double _padding = 20;
  static const double _backClearance = 56;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallback);
    }
  }

  Widget _body(BuildContext context) {
    if (!scroll) return child;
    final top = immersive ? _backClearance : _padding;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(_padding, top, _padding, _padding),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: fillHeight
                  ? (constraints.maxHeight - top - _padding).clamp(
                      0,
                      double.infinity,
                    )
                  : 0,
            ),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }

  Widget _discreetBack(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 4,
      left: 4,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        style: IconButton.styleFrom(
          backgroundColor: scheme.surface.withValues(alpha: 0.55),
          foregroundColor: scheme.onSurfaceVariant,
        ),
        onPressed: () => _back(context),
        icon: const BackButtonIcon(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (immersive) {
      return Scaffold(
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: _body(context)),
              Semantics(
                header: true,
                label: title,
                child: const SizedBox.shrink(),
              ),
              _discreetBack(context),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _back(context)),
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: _body(context)),
    );
  }
}
