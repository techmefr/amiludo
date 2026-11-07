import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Files/file_transfer.dart';

class NotebookImages {
  const NotebookImages({
    required this.importImage,
    required this.readImage,
    this.pick = FileTransfer.openImage,
  });

  final Future<String> Function(List<int> bytes) importImage;
  final Future<Uint8List?> Function(String id) readImage;
  final Future<Uint8List?> Function() pick;

  Future<String?> pickAndImport() async {
    final bytes = await pick();
    return bytes == null ? null : importImage(bytes);
  }
}

class NotebookImage extends StatelessWidget {
  const NotebookImage({
    super.key,
    required this.id,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String id;
  final double? height, width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: context.read<NotebookImages>().readImage(id),
    builder: (context, snapshot) {
      final data = snapshot.data;
      if (data == null) return SizedBox(height: height, width: width);
      return Image.memory(
        data,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
      );
    },
  );
}
