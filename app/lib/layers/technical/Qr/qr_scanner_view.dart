import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({
    super.key,
    required this.onCode,
    required this.unavailable,
    this.height = 320,
  });

  final ValueChanged<String> onCode;
  final String unavailable;
  final double height;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _detect(BarcodeCapture capture) {
    for (final code in capture.barcodes) {
      final value = code.rawValue;
      if (value != null && value.isNotEmpty) widget.onCode(value);
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: SizedBox(
      height: widget.height,
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
    ),
  );
}
