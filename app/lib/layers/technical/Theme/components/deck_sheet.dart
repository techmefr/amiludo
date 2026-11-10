import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';

Future<T?> showDeckSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  List<double>? detents,
}) {
  DeckHaptics.selection();
  Widget content(BuildContext context, ScrollController? controller) =>
      SafeArea(
        child: SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            Space.xl,
            Space.xs,
            Space.xl,
            Space.xl + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: Space.lg),
              builder(context),
            ],
          ),
        ),
      );
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxWidth: Breakpoints.contentWidth(Breakpoints.of(context)),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: Motion.of(context, Motion.base),
      curve: Motion.curve,
    ),
    builder: (context) => detents == null
        ? content(context, null)
        : DraggableScrollableSheet(
            expand: false,
            snap: true,
            initialChildSize: detents.first,
            minChildSize: detents.first,
            maxChildSize: detents.last,
            snapSizes: detents,
            builder: content,
          ),
  );
}
