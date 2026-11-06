import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/icon_catalog.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef DieImageReader = Future<Uint8List?> Function(String id);

class DieFaceView extends StatelessWidget {
  const DieFaceView({
    super.key,
    required this.face,
    required this.body,
    this.size = 56,
    this.reader,
  });
  final DieFaceContent face;
  final Color body;
  final double size;
  final DieImageReader? reader;

  @override
  Widget build(BuildContext context) {
    final ink = face.color == null ? readableOn(body) : Color(face.color!);
    final inner = size * 0.62;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: switch (face.kind) {
          DieFaceKind.text => FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(Space.xs),
              child: Text(
                face.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ink,
                ),
              ),
            ),
          ),
          DieFaceKind.icon => CatalogIcon(face.value, size: inner, color: ink),
          DieFaceKind.image => _FaceImage(
            id: face.value,
            size: inner,
            reader: reader ?? DieStudio.maybeOf(context)?.image,
          ),
        },
      ),
    );
  }
}

class _FaceImage extends StatefulWidget {
  const _FaceImage({required this.id, required this.size, this.reader});
  final String id;
  final double size;
  final DieImageReader? reader;

  @override
  State<_FaceImage> createState() => _FaceImageState();
}

class _FaceImageState extends State<_FaceImage> {
  Future<Uint8List?>? bytes;

  @override
  void initState() {
    super.initState();
    bytes = widget.reader?.call(widget.id);
  }

  @override
  void didUpdateWidget(_FaceImage old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) bytes = widget.reader?.call(widget.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: bytes,
    builder: (context, snapshot) {
      final data = snapshot.data;
      return ClipRRect(
        borderRadius: BorderRadius.circular(Radii.sm),
        child: SizedBox.square(
          dimension: widget.size,
          child: data == null
              ? const SizedBox()
              : Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true),
        ),
      );
    },
  );
}
