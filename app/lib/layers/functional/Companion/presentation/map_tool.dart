import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_canvas.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_controller.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_marker_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_toolbar.dart';
import 'package:amiludo/layers/technical/Drawing/png_encoding.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';

typedef MapImageImporter = Future<String> Function(List<int> bytes);
typedef MapImageReader = Future<Uint8List?> Function(String id);

class MapBoardTool extends StatefulWidget {
  const MapBoardTool({
    super.key,
    this.initial = const MapBoard(),
    this.onChanged,
    this.importImage,
    this.readImage,
    this.pickFile = FileTransfer.openImage,
  });
  final MapBoard initial;
  final ValueChanged<MapBoard>? onChanged;
  final MapImageImporter? importImage;
  final MapImageReader? readImage;
  final Future<Uint8List?> Function() pickFile;

  @override
  State<MapBoardTool> createState() => _MapBoardToolState();
}

class _MapBoardToolState extends State<MapBoardTool> {
  late final controller = MapController(
    widget.initial,
    onChanged: widget.onChanged,
  );
  ui.Image? image;
  String? loadedId;

  @override
  void initState() {
    super.initState();
    controller.addListener(loadImage);
    loadImage();
  }

  @override
  void dispose() {
    controller.dispose();
    image?.dispose();
    super.dispose();
  }

  Future<void> loadImage() async {
    final id = controller.board.imageId;
    if (id == loadedId) return;
    loadedId = id;
    final read = widget.readImage;
    final bytes = id == null || read == null ? null : await read(id);
    final decoded = bytes == null ? null : await decode(bytes);
    if (!mounted || id != loadedId) return decoded?.dispose();
    final old = image;
    setState(() => image = decoded);
    old?.dispose();
  }

  Future<ui.Image?> decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> background(MapBackground choice) async {
    if (choice != MapBackground.image) {
      return controller.setBackground(choice);
    }
    final importer = widget.importImage;
    final raw = await widget.pickFile();
    if (raw == null || importer == null) return;
    final id = await importer(await fitToPng(raw));
    controller.setBackground(MapBackground.image, imageId: id);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      MapToolbar(
        controller: controller,
        onBackground: background,
        onIcon: () => showIconSheet(
          context,
          selected: controller.icon,
          onPick: controller.setIcon,
        ),
      ),
      Expanded(
        child: MapCanvas(
          controller: controller,
          image: image,
          onEdit: (marker) => showMarkerSheet(
            context,
            marker: marker,
            onSave: controller.editMarker,
            onDelete: () => controller.removeMarker(marker.id),
          ),
        ),
      ),
    ],
  );
}
