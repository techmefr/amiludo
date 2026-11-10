import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_view.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_focus.dart';

class CounterTool extends StatefulWidget {
  const CounterTool({super.key, required this.settings, this.name});
  final CounterSettings settings;
  final String? name;

  @override
  State<CounterTool> createState() => _CounterToolState();
}

class _CounterToolState extends State<CounterTool> {
  late final CounterState state = CounterState(
    CounterSettings.fromJson({
      ...widget.settings.toJson(),
      'name': widget.name ?? widget.settings.name,
    }),
  );

  @override
  Widget build(BuildContext context) => Center(
    child: ToolFocus(
      baseWidth: 420,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: CounterView(state: state),
      ),
    ),
  );
}
