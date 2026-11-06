import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_face_ops.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DieBulkPanel extends StatefulWidget {
  const DieBulkPanel({
    super.key,
    required this.design,
    required this.current,
    required this.onChange,
  });
  final DieDesign design;
  final int current;
  final void Function(DieDesign next, {int? focus}) onChange;

  @override
  State<DieBulkPanel> createState() => _DieBulkPanelState();
}

class _DieBulkPanelState extends State<DieBulkPanel> {
  final from = TextEditingController(text: '1');
  final to = TextEditingController(text: '6');
  final start = TextEditingController(text: '1');

  @override
  void dispose() {
    from.dispose();
    to.dispose();
    start.dispose();
    super.dispose();
  }

  int _read(TextEditingController c, int fallback) =>
      int.tryParse(c.text) ?? fallback;

  (int, int) range() {
    final last = widget.design.faces.length;
    final a = _read(from, 1).clamp(1, last);
    final b = _read(to, last).clamp(1, last);
    return a <= b ? (a - 1, b - 1) : (b - 1, a - 1);
  }

  Widget field(TextEditingController c, String label) => SizedBox(
    width: 96,
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = widget.design;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Space.lg),
        Text(l.diceBulk, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: Space.md,
          children: [
            field(from, l.diceBulkFrom),
            field(to, l.diceBulkTo),
            field(start, l.diceBulkStart),
          ],
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            OutlinedButton(
              onPressed: () {
                final (a, b) = range();
                widget.onChange(d.numbered(a, b, start: _read(start, 1)));
              },
              child: Text(l.diceBulkNumber),
            ),
            OutlinedButton(
              onPressed: () {
                final (a, b) = range();
                widget.onChange(d.filled(a, b, d.faces[widget.current]));
              },
              child: Text(l.diceBulkCopy(widget.current + 1)),
            ),
          ],
        ),
      ],
    );
  }
}
