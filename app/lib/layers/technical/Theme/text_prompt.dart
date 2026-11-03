import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

Future<String?> textPrompt(
  BuildContext context,
  String title, {
  String initial = '',
  String? label,
  bool multiline = false,
}) async {
  final controller = TextEditingController(text: initial);

  final route = MaterialPageRoute<String>(
    builder: (page) => FullPage(
      title: title,
      fallback: '/game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            minLines: multiline ? 4 : 1,
            maxLines: multiline ? 8 : 1,
            maxLength: multiline ? 4000 : 100,
            decoration: InputDecoration(labelText: label),
            onSubmitted: multiline ? null : (v) => Navigator.pop(page, v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(page, controller.text),
            child: Text(tr(context, 'Enregistrer', 'Save')),
          ),
        ],
      ),
    ),
  );
  try {
    final value = await Navigator.of(context).push(route);
    await route.completed;
    return value;
  } finally {
    controller.dispose();
  }
}
