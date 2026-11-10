import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class PhysicalToolLayout extends StatelessWidget {
  const PhysicalToolLayout({
    super.key,
    required this.stage,
    required this.controls,
  });

  final Widget stage, controls;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final short = MediaQuery.sizeOf(context).height < 520;
      final sideBySide =
          constraints.maxWidth >= 900 || (short && constraints.maxWidth >= 480);
      return Flex(
        direction: sideBySide ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: sideBySide
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.stretch,
        children: [
          Flexible(flex: 3, child: stage),
          SizedBox(
            width: sideBySide ? Space.lg : 0,
            height: sideBySide ? 0 : Space.md,
          ),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SizedBox(width: double.infinity, child: controls),
              ),
            ),
          ),
        ],
      );
    },
  );
}
