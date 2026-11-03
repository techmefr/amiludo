import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class EveningForm extends StatefulWidget {
  const EveningForm({super.key, required this.id});

  final String id;

  @override
  State<EveningForm> createState() => _EveningFormState();
}

class _EveningFormState extends State<EveningForm> {
  late Evening evening;
  late final TextEditingController title, place;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EveningsCubit>();
    evening = cubit.evening(widget.id) ?? cubit.draft();
    title = TextEditingController(text: evening.title);
    place = TextEditingController(text: evening.place);
  }

  @override
  void dispose() {
    title.dispose();
    place.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final local = evening.startsAt.toLocal();
    final day = await showDatePicker(
      context: context,
      initialDate: local,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(local),
    );
    if (time == null || !mounted) return;
    setState(
      () => evening = evening.copyWith(
        startsAt: DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        ).toUtc(),
      ),
    );
  }

  Future<void> _save() async {
    final cubit = context.read<EveningsCubit>();
    final updated = evening.copyWith(
      title: title.text.trim(),
      place: place.text.trim(),
    );
    try {
      await cubit.save(updated);
      if (mounted) context.go('/evenings/${updated.id}');
    } catch (error) {
      if (mounted) notify(context, eveningErrorText(context, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<EveningsCubit>().state.shelf;
    return FullPage(
      title: tr(context, 'Soirée', 'Game night'),
      fallback: '/evenings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: title,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: tr(context, 'Titre', 'Title'),
              hintText: tr(context, 'Soirée jeux chez Léa', 'Games at Léa’s'),
            ),
          ),
          TextField(
            controller: place,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: tr(context, 'Lieu', 'Place'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(eveningWhen(context, evening.startsAt)),
            trailing: TextButton(
              onPressed: _pickDate,
              child: Text(tr(context, 'Changer', 'Change')),
            ),
          ),
          SectionHeading(
            evening.seats == 0
                ? tr(context, 'Places : sans limite', 'Seats: no limit')
                : tr(
                    context,
                    'Places : ${evening.seats} (vous compris)',
                    'Seats: ${evening.seats} (you included)',
                  ),
          ),
          Slider(
            max: 20,
            divisions: 20,
            value: evening.seats.toDouble(),
            label: evening.seats == 0 ? '∞' : '${evening.seats}',
            onChanged: (v) =>
                setState(() => evening = evening.copyWith(seats: v.round())),
          ),
          if (shelf.isNotEmpty)
            _PlannedGames(
              names: shelf.map((g) => g.name).toList(),
              selected: evening.gameNames,
              onChanged: (names) =>
                  setState(() => evening = evening.copyWith(gameNames: names)),
            ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: Text(tr(context, 'Enregistrer', 'Save')),
          ),
        ],
      ),
    );
  }
}

class _PlannedGames extends StatelessWidget {
  const _PlannedGames({
    required this.names,
    required this.selected,
    required this.onChanged,
  });

  final List<String> names, selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeading(tr(context, 'Jeux prévus', 'Planned games')),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final name in names)
            FilterChip(
              label: Text(name),
              selected: selected.contains(name),
              onSelected: (on) => onChanged(
                on
                    ? [...selected, name]
                    : selected.where((n) => n != name).toList(),
              ),
            ),
        ],
      ),
    ],
  );
}
