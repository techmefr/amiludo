import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<ui.FragmentProgram?> loadHoloProgram() async {
  try {
    return await ui.FragmentProgram.fromAsset('shaders/holo.frag');
  } on Object {
    return null;
  }
}

class HoloFoil extends StatefulWidget {
  const HoloFoil({
    super.key,
    required this.child,
    this.strength = 1,
    this.radius = Radii.lg,
    this.tilt,
  });

  final Widget child;
  final double strength, radius;
  final ValueNotifier<Offset>? tilt;

  @override
  State<HoloFoil> createState() => _HoloFoilState();
}

class _HoloFoilState extends State<HoloFoil> {
  static Future<ui.FragmentProgram?>? _program;
  final _pointer = ValueNotifier<Offset>(const Offset(.3, .25));

  @override
  void initState() {
    super.initState();
    _program ??= loadHoloProgram();
  }

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  void _move(PointerEvent e, Size size) {
    if (size.isEmpty) return;
    _pointer.value = Offset(
      (e.localPosition.dx / size.width).clamp(0, 1),
      (e.localPosition.dy / size.height).clamp(0, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        return Listener(
          onPointerHover: (e) => _move(e, size),
          onPointerMove: (e) => _move(e, size),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: still
                        ? _Sheen(radius: widget.radius)
                        : _Foil(
                            program: _program!,
                            pointer: widget.tilt ?? _pointer,
                            strength: widget.strength,
                            radius: widget.radius,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Sheen extends StatelessWidget {
  const _Sheen({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: .0),
          Colors.white.withValues(alpha: .14),
          Colors.white.withValues(alpha: .0),
        ],
      ),
    ),
  );
}

class _Foil extends StatelessWidget {
  const _Foil({
    required this.program,
    required this.pointer,
    required this.strength,
    required this.radius,
  });

  final Future<ui.FragmentProgram?> program;
  final ValueNotifier<Offset> pointer;
  final double strength, radius;

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.FragmentProgram?>(
    future: program,
    builder: (context, snapshot) {
      final loaded = snapshot.data;
      if (loaded == null) return _Sheen(radius: radius);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ValueListenableBuilder<Offset>(
          valueListenable: pointer,
          builder: (_, tilt, _) => CustomPaint(
            painter: _FoilPainter(loaded.fragmentShader(), tilt, strength),
          ),
        ),
      );
    },
  );
}

class _FoilPainter extends CustomPainter {
  _FoilPainter(this.shader, this.tilt, this.strength);

  final ui.FragmentShader shader;
  final Offset tilt;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, tilt.dx)
      ..setFloat(3, tilt.dy)
      ..setFloat(4, strength);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_FoilPainter old) =>
      old.tilt != tilt || old.strength != strength;
}
