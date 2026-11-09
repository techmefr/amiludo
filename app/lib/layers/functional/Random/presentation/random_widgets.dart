import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';

String randomInputErrorText(BuildContext context, RandomInputError error) =>
    switch (error) {
      RandomInputError.invalidBounds =>
        context.l10n.randomEnterTwoWholeNumbersThe,
      RandomInputError.emptyBag => context.l10n.randomTheBagIsEmptyRefill,
      RandomInputError.roleCount => context.l10n.randomProvideExactlyOneRolePer,
      RandomInputError.wheelSize => context.l10n.randomPickBetween2And50,
      RandomInputError.wheelWeight => context.l10n.randomWeightAWholeNumberFrom,
    };

class RandomResult extends StatelessWidget {
  const RandomResult({super.key, required this.text, this.compact = false});
  final String text;
  final bool compact;
  @override
  Widget build(BuildContext context) =>
      ToolResultText(text: text, compact: compact);
}

class RandomResultSlot extends StatelessWidget {
  const RandomResultSlot({super.key, required this.text, this.compact = false});
  final String text;
  final bool compact;
  @override
  Widget build(BuildContext context) => text.isEmpty
      ? const SizedBox(height: 20)
      : RandomResult(text: text, compact: compact);
}

class RandomOptionsField extends StatelessWidget {
  const RandomOptionsField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.helper,
  });
  final TextEditingController controller;
  final String label;
  final String? helper;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    minLines: 2,
    maxLines: 5,
    decoration: InputDecoration(labelText: label, helperText: helper),
    onChanged: (_) => onChanged(),
  );
}

class RandomDrawButton extends StatelessWidget {
  const RandomDrawButton({super.key, required this.onPressed, this.label});
  final VoidCallback? onPressed;
  final String? label;
  @override
  Widget build(BuildContext context) => ToolPrimaryButton(
    onPressed: onPressed,
    label: label ?? context.l10n.randomDraw,
  );
}
