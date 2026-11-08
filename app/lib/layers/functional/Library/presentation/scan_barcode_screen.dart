import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/barcode_match.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/barcode_scan_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_sheet.dart';
import 'package:amiludo/layers/technical/Barcode/barcode_scanner_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key, required this.scanner});

  final BarcodeScannerBuilder scanner;

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final code = TextEditingController();
  final name = TextEditingController();
  ShelfGame? owned;
  List<BarcodeProduct> results = const [];

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    super.dispose();
  }

  void _submit() {
    if (isValidBarcode(barcodeDigits(code.text))) {
      _resolve(code.text);
    } else {
      notify(context, context.l10n.libraryScanCodeInvalid);
    }
  }

  Future<void> _resolve(String raw) async {
    final cubit = context.read<BarcodeScanCubit>();
    final match = await cubit.resolve(raw);
    if (match == null || !mounted) return;
    HapticFeedback.mediumImpact();
    final found = match.owned;
    if (found != null) {
      setState(() => owned = found);
      return;
    }
    final l10n = context.l10n;
    final product = match.product;
    notify(
      context,
      product != null
          ? l10n.libraryScanFound
          : match.unreachable
          ? l10n.libraryScanOffline
          : l10n.libraryScanUnknown,
    );
    _draft(product, barcode: match.code);
  }

  void _draft(BarcodeProduct? product, {String barcode = ''}) =>
      context.pushReplacement(
        '/library/edit/new',
        extra: ShelfGame(
          id: newId(),
          name: product?.title ?? '',
          barcode: barcode,
          imageUrl: product?.imageUrl ?? '',
          addedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<void> _search() async {
    final found = await context.read<BarcodeScanCubit>().searchOnline(
      name.text,
    );
    if (mounted) setState(() => results = found);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FullPage(
      title: l10n.libraryScanTitle,
      fallback: '/library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.libraryScanHint),
          const SizedBox(height: 16),
          if (cameraScanSupported)
            SizedBox(
              height: 260,
              child: widget.scanner(_resolve, l10n.libraryScanUnavailable),
            ),
          BlocBuilder<BarcodeScanCubit, bool>(
            builder: (context, busy) =>
                busy ? const LinearProgressIndicator() : const SizedBox(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: code,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: l10n.libraryScanCodeField),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _submit, child: Text(l10n.libraryScanLookUp)),
          if (owned case final game?) _OwnedCard(game: game),
          if (context.read<BarcodeScanCubit>().canSearchOnline)
            _OnlineSearch(
              controller: name,
              results: results,
              onSearch: _search,
              onPick: _draft,
            ),
        ],
      ),
    );
  }
}

class _OwnedCard extends StatelessWidget {
  const _OwnedCard({required this.game});

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

class _OnlineSearch extends StatelessWidget {
  const _OnlineSearch({
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
