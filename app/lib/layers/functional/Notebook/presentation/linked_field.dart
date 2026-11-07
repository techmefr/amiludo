import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/linked_text.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class LinkedField extends StatefulWidget {
  const LinkedField({
    super.key,
    required this.text,
    required this.entries,
    required this.onChanged,
    required this.onOpen,
    required this.hint,
  });

  final String text, hint;
  final List<NotebookEntry> entries;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onOpen;

  @override
  State<LinkedField> createState() => _LinkedFieldState();
}

class _LinkedFieldState extends State<LinkedField> {
  late final controller = TextEditingController(text: widget.text);
  var editing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return TextField(
        controller: controller,
        autofocus: true,
        minLines: 3,
        maxLines: null,
        decoration: InputDecoration(hintText: widget.hint),
        onChanged: widget.onChanged,
        onTapOutside: (_) => setState(() => editing = false),
      );
    }
    final empty = controller.text.trim().isEmpty;
    return InkWell(
      onTap: () => setState(() => editing = true),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Targets.minimum),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: empty
              ? Text(
                  widget.hint,
                  style: TextStyle(color: Theme.of(context).hintColor),
                )
              : LinkedText(
                  text: controller.text,
                  entries: widget.entries,
                  onOpen: widget.onOpen,
                ),
        ),
      ),
    );
  }
}
