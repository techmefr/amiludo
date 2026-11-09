import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef BarcodeScannerBuilder = Widget Function(
  ValueChanged<String> onCode,
  String unavailable,
);

bool get cameraScanSupported =>
    kIsWeb ||
    const {
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);

Widget defaultBarcodeScanner(ValueChanged<String> onCode, String unavailable) =>
    BarcodeScannerView(onCode: onCode, unavailable: unavailable);

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    super.key,
    required this.onCode,
    required this.unavailable,
  });

  final ValueChanged<String> onCode;
  final String unavailable;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  String? last;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _detect(BarcodeCapture capture) {
    for (final code in capture.barcodes) {
      final value = code.rawValue;
      if (value == null || value.isEmpty || value == last) continue;
      last = value;
      widget.onCode(value);
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: MobileScanner(
      controller: controller,
      onDetect: _detect,
      errorBuilder: (context, error) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(widget.unavailable, textAlign: TextAlign.center),
          ),
        ),
      ),
    ),
  );
}
