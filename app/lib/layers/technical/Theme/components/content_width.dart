import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth});
  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? Breakpoints.contentWidth(Breakpoints.of(context)),
      ),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
