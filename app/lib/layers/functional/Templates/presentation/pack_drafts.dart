import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

typedef Refresh = void Function(VoidCallback change);

class BuilderField extends StatelessWidget {
  const BuilderField(
    this.controller,
    this.label, {
    super.key,
    this.lines = 1,
    this.maxLength,
    this.hint,
  });
  final TextEditingController controller;
  final String label;
  final int lines;
  final int? maxLength;
  final String? hint;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      maxLines: lines,
      minLines: lines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 3,
      ),
    ),
  );
}

class RemoveDraftButton extends StatelessWidget {
  const RemoveDraftButton(this.label, this.onRemove, {super.key});
  final String label;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onRemove,
    icon: const DeckIcon(Icons.delete_outline),
    label: Text(label),
  );
}

void disposeLater(VoidCallback dispose) =>
    WidgetsBinding.instance.addPostFrameCallback((_) => dispose());

class FaceDraft {
  FaceDraft(DieFace? f)
    : label = TextEditingController(text: f?.label ?? ''),
      value = TextEditingController(text: '${f?.value ?? 0}');
  final TextEditingController label, value;
  DieFace build() => DieFace.fromJson({
    'label': label.text.trim(),
    'value': double.parse(value.text.replaceAll(',', '.')),
  });
  void dispose() {
    label.dispose();
    value.dispose();
  }
}

class DieDraft {
  DieDraft(GameDie? d)
    : name = TextEditingController(text: d?.name ?? 'Dé classique'),
      count = TextEditingController(text: '${d?.count ?? 1}'),
      faces =
          (d?.faces ??
                  List.generate(
                    6,
                    (i) => DieFace('${i + 1}', (i + 1).toDouble()),
                  ))
              .map(FaceDraft.new)
              .toList();
  final TextEditingController name, count;
  final List<FaceDraft> faces;
  GameDie value() => GameDie.fromJson({
    'name': name.text.trim(),
    'count': int.parse(count.text),
    'faces': faces.map((f) => f.build().toJson()).toList(),
  });
  void dispose() {
    name.dispose();
    count.dispose();
    for (final f in faces) {
      f.dispose();
    }
  }
}

class RoleDraft {
  RoleDraft(GameRole? r)
    : name = TextEditingController(text: r?.name ?? ''),
      count = TextEditingController(text: '${r?.count ?? 1}'),
      description = TextEditingController(text: r?.description ?? '');
  final TextEditingController name, count, description;
  GameRole value() => GameRole.fromJson({
    'name': name.text.trim(),
    'count': int.parse(count.text),
    'description': description.text.trim(),
  });
  void dispose() {
    name.dispose();
    count.dispose();
    description.dispose();
  }
}

class RuleDraft {
  RuleDraft(ScoreRule? r)
    : name = TextEditingController(text: r?.name ?? ''),
      factor = TextEditingController(text: '${r?.factor ?? 1}'),
      step = TextEditingController(text: '${r?.step ?? 1}'),
      bonus = TextEditingController(text: '${r?.bonus ?? 0}'),
      table = TextEditingController(text: r?.table.join(', ') ?? ''),
      kind = r?.kind ?? 'linear';
  final TextEditingController name, factor, step, bonus, table;
  String kind;
  ScoreRule value() => ScoreRule.fromJson({
    'name': name.text.trim(),
    'kind': kind,
    'factor': double.parse(factor.text.replaceAll(',', '.')),
    'step': double.parse(step.text.replaceAll(',', '.')),
    'bonus': double.parse(bonus.text.replaceAll(',', '.')),
    'table': kind == 'lookup'
        ? table.text.split(',').map((s) => double.parse(s.trim())).toList()
        : <double>[],
  });
  void dispose() {
    name.dispose();
    factor.dispose();
    step.dispose();
    bonus.dispose();
    table.dispose();
  }
}

class ResourceDraft {
  ResourceDraft([String name = '', double start = 0])
    : name = TextEditingController(text: name),
      start = TextEditingController(text: '$start');
  final TextEditingController name, start;
  MapEntry<String, double> value() =>
      MapEntry(name.text.trim(), double.parse(start.text.replaceAll(',', '.')));
  void dispose() {
    name.dispose();
    start.dispose();
  }
}
