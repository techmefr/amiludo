import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class MasterDetail extends StatelessWidget {
  const MasterDetail({
    super.key,
    required this.master,
    required this.detail,
    required this.hasSelection,
    this.placeholder,
    this.masterWidth = 380,
  });
  final Widget master, detail;
  final Widget? placeholder;
  final bool hasSelection;
  final double masterWidth;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.atLeast(context, WindowClass.expanded)) {
      return hasSelection ? detail : master;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: masterWidth, child: master),
        const SizedBox(width: Space.xl),
        Expanded(
          child: hasSelection
              ? detail
              : (placeholder ?? const SizedBox.shrink()),
        ),
      ],
    );
  }
}
