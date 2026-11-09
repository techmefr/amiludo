import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImmersiveChrome extends StatefulWidget {
  const ImmersiveChrome({
    super.key,
    required this.onBack,
    required this.child,
    this.bindings = const {},
  });
  final VoidCallback onBack;
  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;

  @override
  State<ImmersiveChrome> createState() => _ImmersiveChromeState();
}

class _ImmersiveChromeState extends State<ImmersiveChrome> {
  static int _depth = 0;

  @override
  void initState() {
    super.initState();
    _depth++;
    _apply(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _depth--;
    if (_depth == 0) _apply(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  static void _apply(SystemUiMode mode) {
    unawaited(SystemChrome.setEnabledSystemUIMode(mode).catchError((_) {}));
  }

  void _escape() {
    final focus = FocusManager.instance.primaryFocus;
    final typing =
        focus?.context?.findAncestorWidgetOfExactType<EditableText>() != null;
    if (!typing) widget.onBack();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): _escape,
      const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
          widget.onBack,
      ...widget.bindings,
    },
    child: Focus(autofocus: true, child: widget.child),
  );
}
