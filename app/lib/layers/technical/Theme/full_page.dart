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
  });
  final String title, fallback;
  final Widget child;
  final bool scroll;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(fallback);
          }
        },
      ),
      title: Text(title),
      actions: actions,
    ),
    body: SafeArea(
      child: scroll
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: child,
                ),
              ),
            )
          : child,
    ),
  );
}
