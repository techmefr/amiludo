import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/entry_links.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class LinkedText extends StatefulWidget {
  const LinkedText({
    super.key,
    required this.text,
    required this.entries,
    required this.onOpen,
    this.style,
  });

  final String text;
  final List<NotebookEntry> entries;
  final ValueChanged<String> onOpen;
  final TextStyle? style;

  @override
  State<LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<LinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  List<InlineSpan> _spans(TextStyle base) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final link = base.copyWith(
      color: Theme.of(context).colorScheme.accentText,
      decoration: TextDecoration.underline,
    );
    return [
      for (final s in linkSegments(widget.text, widget.entries))
        if (s.entryId == null)
          TextSpan(text: s.text)
        else
          TextSpan(text: s.text, style: link, recognizer: _tap(s.entryId!)),
    ];
  }

  TapGestureRecognizer _tap(String id) {
    final recognizer = TapGestureRecognizer()..onTap = () => widget.onOpen(id);
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style ?? Theme.of(context).textTheme.bodyMedium!;
    return Text.rich(TextSpan(style: base, children: _spans(base)));
  }
}
