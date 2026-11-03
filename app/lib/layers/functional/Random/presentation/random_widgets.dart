import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';

String randomInputErrorText(BuildContext context, RandomInputError error) =>
    switch (error) {
      RandomInputError.invalidBounds => tr(
        context,
        'Saisissez deux nombres entiers, le minimum avant le maximum.',
        'Enter two whole numbers, the minimum before the maximum.',
      ),
      RandomInputError.emptyBag => tr(
        context,
        'Le sac est vide. Remplissez-le pour recommencer.',
        'The bag is empty. Refill it to start again.',
      ),
      RandomInputError.roleCount => tr(
        context,
        'Prévoyez exactement un rôle par joueur.',
        'Provide exactly one role per player.',
      ),
      RandomInputError.wheelSize => tr(
        context,
        'Choisissez entre 2 et 50 options.',
        'Pick between 2 and 50 options.',
      ),
      RandomInputError.wheelWeight => tr(
        context,
        'Poids : un entier de 1 à 1 000 000.',
        'Weight: a whole number from 1 to 1,000,000.',
      ),
    };

class RandomResult extends StatelessWidget {
  const RandomResult({super.key, required this.text, this.compact = false});
  final String text;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Semantics(
        liveRegion: true,
        child: SelectableText(
          text,
          style: compact ? theme.titleLarge : theme.headlineLarge,
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    child: Text(label ?? tr(context, 'Tirer au sort', 'Draw')),
  );
}
