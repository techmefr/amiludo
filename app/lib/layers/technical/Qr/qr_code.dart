import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCode extends StatelessWidget {
  const QrCode({super.key, required this.data, this.size = 280, this.label});

  final String data;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: label,
    child: ColoredBox(
      color: Colors.white,
      child: QrImageView(
        data: data,
        size: size,
        padding: const EdgeInsets.all(14),
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        gapless: true,
      ),
    ),
  );
}

class AnimatedQr extends StatefulWidget {
  const AnimatedQr({
    super.key,
    required this.frame,
    this.size = 320,
    this.interval = const Duration(milliseconds: 100),
    this.label,
  });

  final String Function(int seq) frame;
  final double size;
  final Duration interval;
  final String? label;

  @override
  State<AnimatedQr> createState() => _AnimatedQrState();
}

class _AnimatedQrState extends State<AnimatedQr> {
  late final Timer _timer;
  int seq = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) => setState(() => seq++));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      QrCode(data: widget.frame(seq), size: widget.size, label: widget.label);
}
