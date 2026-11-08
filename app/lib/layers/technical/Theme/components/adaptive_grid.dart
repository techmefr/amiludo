import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

SliverGridDelegateWithMaxCrossAxisExtent adaptiveGridDelegate({
  double maxExtent = 280,
  double gap = Space.lg,
  double? mainAxisExtent,
  double aspectRatio = 1,
}) => mainAxisExtent == null
    ? SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: aspectRatio,
      )
    : SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: mainAxisExtent,
      );
