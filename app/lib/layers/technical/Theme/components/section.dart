import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/type_roles.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.kicker,
    this.action,
    this.caption,
  });
  final String title;
  final String? kicker, caption;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kicker != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Text(
                kicker!,
                style: TypeRoles.kicker(context)
                    .copyWith(color: scheme.accentText),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: TypeRoles.sectionTitle(context)),
                ),
              ),
              ?action,
            ],
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text(caption!, style: TypeRoles.caption(context)),
            ),
          const SizedBox(height: Space.md),
          child,
        ],
      ),
    );
  }
}
