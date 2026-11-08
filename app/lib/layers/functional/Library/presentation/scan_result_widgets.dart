import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_sheet.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class OwnedCard extends StatelessWidget {
  const OwnedCard({super.key, required this.game});

  final ShelfGame game;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 16),
    child: ListTile(
      title: Text(game.name),
      subtitle: Text(context.l10n.libraryScanOwned),
      trailing: TextButton(
        onPressed: () => showShelfGameSheet(context, game),
        child: Text(context.l10n.libraryScanOpen),
      ),
    ),
  );
}

class OnlineSearch extends StatelessWidget {
  const OnlineSearch({
    super.key,
    required this.controller,
    required this.results,
    required this.onSearch,
    required this.onPick,
  });

  final TextEditingController controller;
  final List<BarcodeProduct> results;
  final VoidCallback onSearch;
  final ValueChanged<BarcodeProduct> onPick;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          labelText: context.l10n.librarySearchOnline,
        ),
      ),
      for (final r in results)
        ListTile(title: Text(r.title), onTap: () => onPick(r)),
    ],
  );
}

class CollectionImport extends StatefulWidget {
  const CollectionImport({super.key, required this.onImport});

  final Future<int?> Function(String username) onImport;

  @override
  State<CollectionImport> createState() => _CollectionImportState();
}

class _CollectionImportState extends State<CollectionImport> {
  final username = TextEditingController();
  String? message;

  @override
  void dispose() {
    username.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final added = await widget.onImport(username.text);
    if (!mounted) return;
    setState(
      () => message = added == null
          ? l10n.libraryImportFailed
          : l10n.libraryImportDone,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      TextField(
        controller: username,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _import(),
        decoration: InputDecoration(
          labelText: context.l10n.libraryImportUsername,
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: _import,
        child: Text(context.l10n.libraryImportBgg),
      ),
      if (message case final text?)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(text, key: const ValueKey('import-message')),
        ),
    ],
  );
}
