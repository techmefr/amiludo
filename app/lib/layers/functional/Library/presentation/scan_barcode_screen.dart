import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/barcode_match.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/barcode_scan_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/scan_result_widgets.dart';
import 'package:amiludo/layers/technical/Barcode/barcode_scanner_view.dart';
import 'package:amiludo/layers/technical/Barcode/scan_frame.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
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

  Widget _camera(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560),
    child: AspectRatio(
      aspectRatio: 4 / 3,
      child: BlocBuilder<BarcodeScanCubit, bool>(
        builder: (context, busy) => ScanFrame(
          busy: busy,
          label: busy
              ? context.l10n.libraryScanLookingUp
              : context.l10n.libraryScanTitle,
          child: widget.scanner(_resolve, context.l10n.libraryScanUnavailable),
        ),
      ),
    ),
  );

  Widget _form(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.libraryScanHint),
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
        AnimatedSize(
          duration: Motion.of(context, Motion.base),
          curve: Motion.curve,
          alignment: Alignment.topCenter,
          child: owned == null ? const SizedBox() : OwnedCard(game: owned!),
        ),
        if (context.read<BarcodeScanCubit>().canSearchOnline)
          CollectionImport(
            onImport: context.read<BarcodeScanCubit>().importCollection,
          ),
        if (context.read<BarcodeScanCubit>().canSearchOnline)
          OnlineSearch(
            controller: name,
            results: results,
            onSearch: _search,
            onPick: _draft,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.libraryScanTitle,
    fallback: '/library',
    child: LayoutBuilder(
      builder: (context, c) {
        final camera = cameraScanSupported;
        if (!camera) return _form(context);
        if (c.maxWidth < 900) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _camera(context),
              const SizedBox(height: 16),
              _form(context),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _camera(context)),
            const SizedBox(width: 32),
            Expanded(child: _form(context)),
          ],
        );
      },
    ),
  );
}
