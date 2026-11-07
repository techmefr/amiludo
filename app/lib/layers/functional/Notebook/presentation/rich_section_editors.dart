import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/notebook_images.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/section_editors.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class StatsEditor extends StatelessWidget {
  const StatsEditor({super.key, required this.section, required this.onChange});
  final EntrySection section;
  final SectionChange onChange;

  void _set(int i, StatLine line) => onChange(
    section.copyWith(
      stats: [
        for (var j = 0; j < section.stats.length; j++)
          j == i ? line : section.stats[j],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        for (var i = 0; i < section.stats.length; i++)
          Row(
            key: ValueKey('${section.id}-$i-${section.stats.length}'),
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: section.stats[i].name,
                  decoration: InputDecoration(hintText: l.notebookStatName),
                  onChanged: (v) =>
                      _set(i, StatLine(name: v, value: section.stats[i].value)),
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: TextFormField(
                  initialValue: section.stats[i].value,
                  decoration: InputDecoration(hintText: l.notebookStatValue),
                  onChanged: (v) =>
                      _set(i, StatLine(name: section.stats[i].name, value: v)),
                ),
              ),
              IconButton(
                tooltip: l.notebookRemove,
                onPressed: () => onChange(
                  section.copyWith(stats: [...section.stats]..removeAt(i)),
                ),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        TextButton.icon(
          onPressed: () => onChange(
            section.copyWith(
              stats: [
                ...section.stats,
                const StatLine(name: '', value: ''),
              ],
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(l.notebookAddStat),
        ),
      ],
    );
  }
}

class PicturesEditor extends StatelessWidget {
  const PicturesEditor({
    super.key,
    required this.section,
    required this.onChange,
  });
  final EntrySection section;
  final SectionChange onChange;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const size = Space.section * 2;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final id in section.pictures)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.sm),
                child: NotebookImage(id: id, width: size, height: size),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IconButton.filledTonal(
                  tooltip: l.notebookRemove,
                  onPressed: () => onChange(
                    section.copyWith(
                      pictures: [...section.pictures]..remove(id),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        OutlinedButton.icon(
          onPressed: () async {
            final id = await context.read<NotebookImages>().pickAndImport();
            if (id != null) {
              onChange(section.copyWith(pictures: [...section.pictures, id]));
            }
          },
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(l.notebookAddPicture),
        ),
      ],
    );
  }
}
