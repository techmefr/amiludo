import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_fog.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_pins.dart';
import 'package:amiludo/layers/functional/World/presentation/draw_tool.dart';
import 'package:amiludo/layers/functional/World/presentation/floor_bar.dart';
import 'package:amiludo/layers/functional/World/presentation/mini_map.dart';
import 'package:amiludo/layers/functional/World/presentation/new_map_sheet.dart';
import 'package:amiludo/layers/functional/World/presentation/pin_sheet.dart';
import 'package:amiludo/layers/functional/World/presentation/world_canvas.dart';
import 'package:amiludo/layers/functional/World/presentation/world_header.dart';
import 'package:amiludo/layers/functional/World/presentation/world_search_sheet.dart';
import 'package:amiludo/layers/functional/World/presentation/world_toolbar.dart';
import 'package:amiludo/layers/functional/World/presentation/world_transfer.dart';
import 'package:amiludo/layers/functional/World/presentation/world_viewport.dart';
import 'package:amiludo/layers/functional/World/presentation/zoom_buttons.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/text_input_dialog.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class WorldTool extends StatefulWidget {
  const WorldTool({
    super.key,
    this.initial = const WorldAtlas(),
    this.onChanged,
    this.creatureNames = const {},
    this.sceneNames = const {},
  });
  final WorldAtlas initial;
  final ValueChanged<WorldAtlas>? onChanged;
  final Map<String, String> creatureNames, sceneNames;

  @override
  State<WorldTool> createState() => _WorldToolState();
}

class _WorldToolState extends State<WorldTool> {
  late WorldAtlas atlas = widget.initial;
  final controller = WorldViewportController();
  String? mapId;
  String? floorId;
  DrawTool tool = DrawTool.move;
  double brush = brushSizes[1];
  String? measured;
  bool playerView = false;

  WorldMap? get map => atlas.of(mapId ?? '') ?? atlas.maps.firstOrNull;

  String get floor {
    final m = map!;
    return m.floor(floorId ?? '')?.id ??
        (m.floors.where((f) => f.name == '0').firstOrNull ?? m.floors.first).id;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _commit(WorldAtlas next) {
    setState(() => atlas = next);
    widget.onChanged?.call(next);
  }

  void _edit(WorldMap Function(WorldMap) change) =>
      _commit(atlas.put(change(map!)));

  void _openMap(String id) {
    if (atlas.of(id) == null) return;
    setState(() {
      mapId = id;
      floorId = null;
    });
    controller.reset();
  }

  Future<void> _placePin(WorldPoint at) async {
    final fresh = MapPin(
      id: newElementId(),
      kind: PinKind.place,
      point: at,
      title: '',
    );
    final target = floor;
    final made = await showPinSheet(
      context,
      pin: fresh,
      isNew: true,
      creatures: widget.creatureNames,
      scenes: widget.sceneNames,
      maps: _otherMaps(),
    );
    if (made == null) return;
    _edit((m) => m.addPin(target, made));
  }

  Future<void> _openPin(MapPin pin) async {
    final made = await showPinSheet(
      context,
      pin: pin,
      isNew: false,
      creatures: widget.creatureNames,
      scenes: widget.sceneNames,
      maps: _otherMaps(),
      onDelete: () => _edit((m) => m.removePin(pin.id)),
      onOpenMap: _openMap,
    );
    if (made == null) return;
    _edit((m) => m.updatePin(made));
  }

  Map<String, String> _otherMaps() => {
    for (final m in atlas.maps)
      if (m.id != map!.id) m.id: m.name,
  };

  void _movePin(String id, Offset delta) {
    final pin = map!.floor(floor)!.pins.where((p) => p.id == id).firstOrNull;
    if (pin == null) return;
    final to = WorldPoint(pin.point.x + delta.dx, pin.point.y + delta.dy);
    _edit((m) => m.updatePin(pin.copyWith(point: to)));
  }

  Future<void> _search() async {
    final hit = await showWorldSearch(context, atlas);
    if (hit == null) return;
    setState(() {
      mapId = hit.map.id;
      floorId = hit.floor.id;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.centerOn(hit.pin.point),
    );
  }

  Future<void> _newMap() async {
    final made = await showNewMapSheet(context);
    if (made == null) return;
    _commit(atlas.put(made));
    setState(() {
      mapId = made.id;
      floorId = null;
    });
    controller.reset();
  }

  Future<void> _deleteMap() async {
    final l = context.l10n;
    final current = map!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.worldDeleteMapTitle(current.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(MaterialLocalizations.of(dialog).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.worldDeleteMap),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _commit(atlas.remove(current.id));
    setState(() {
      mapId = null;
      floorId = null;
    });
  }

  Future<void> _floorAction(FloorAction action) async {
    final current = map!;
    switch (action) {
      case FloorAction.above:
        final name = current.nextFloorName();
        _edit((m) => m.addFloor(name));
        setState(() => floorId = atlas.of(current.id)!.floors.last.id);
      case FloorAction.below:
        final name = current.nextFloorName(below: true);
        _edit((m) => m.addFloor(name, below: true));
        setState(() => floorId = atlas.of(current.id)!.floors.first.id);
      case FloorAction.rename:
        final l = context.l10n;
        final target = floor;
        final text = await showTextInputDialog(
          context,
          title: l.worldRenameFloor,
          label: l.worldFloorName,
          confirm: l.worldSave,
          initial: current.floor(target)!.name,
        );
        if (text == null || text.trim().isEmpty) return;
        _edit((m) => m.renameFloor(target, text.trim()));
      case FloorAction.remove:
        _edit((m) => m.removeFloor(floor));
        setState(() => floorId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = map;
    if (current == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.worldEmpty, textAlign: TextAlign.center),
              const SizedBox(height: Space.lg),
              FilledButton.icon(
                onPressed: _newMap,
                icon: const DeckIcon(Icons.add),
                label: Text(l.worldNewMap),
              ),
            ],
          ),
        ),
      );
    }
    final active = floor;
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WorldHeader(
                    atlas: atlas,
                    selected: current.id,
                    grid: current.grid,
                    onSelect: (id) => setState(() {
                      mapId = id;
                      floorId = null;
                    }),
                    onNew: _newMap,
                    onGrid: () => _edit((m) => m.copyWith(grid: !m.grid)),
                    onExport: () => copyAtlas(context, atlas),
                    onImport: () async {
                      final merged = await importAtlas(context, atlas);
                      if (merged != null) _commit(merged);
                    },
                    onDelete: _deleteMap,
                    onSearch: _search,
                    fog: current.fog,
                    playerView: playerView,
                    onFog: () => _edit((m) => m.copyWith(fog: !m.fog)),
                    onPlayerView: () => setState(() {
                      playerView = !playerView;
                      tool = DrawTool.move;
                    }),
                  ),
                  if (!playerView)
                    WorldToolbar(
                      tool: tool,
                      brush: brush,
                      onTool: (t) => setState(() => tool = t),
                      onBrush: (b) => setState(() => brush = b),
                      onUndo: () => _edit((m) => m.undo(active)),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: l.worldCanvasLabel(
                      current.name,
                      current.floor(active)!.name,
                    ),
                    child: WorldCanvas(
                      map: current,
                      floorId: active,
                      tool: tool,
                      brush: brush,
                      controller: controller,
                      onAdd: (MapElement e) =>
                          _edit((m) => m.addElement(active, e)),
                      onErase: (id) => _edit((m) => m.removeElement(id)),
                      playerView: playerView,
                      onReveal: (p) => _edit((m) => m.toggleReveal(active, p)),
                      onPlacePin: _placePin,
                      onOpenPin: (p) {
                        if (!playerView) _openPin(p);
                      },
                      onMovePin: _movePin,
                      onMeasure: (text) => setState(() => measured = text),
                    ),
                  ),
                ),
                Positioned(
                  left: Space.sm,
                  bottom: Space.sm,
                  child: Wrap(
                    spacing: Space.xs,
                    children: [
                      Chip(label: Text(l.worldCell(current.level.cellLabel))),
                      if (measured != null)
                        Chip(label: Text(l.worldMeasured(measured!))),
                    ],
                  ),
                ),
                Positioned(
                  right: Space.sm,
                  top: Space.sm,
                  child: playerView
                      ? const SizedBox.shrink()
                      : MiniMap(
                          floor: current.floor(active)!,
                          controller: controller,
                          onJump: controller.centerOn,
                        ),
                ),
                Positioned(
                  right: Space.sm,
                  bottom: Space.sm,
                  child: ZoomButtons(controller: controller),
                ),
              ],
            ),
          ),
          FloorBar(
            floors: current.floors.reversed.toList(),
            selected: active,
            onSelect: (id) => setState(() => floorId = id),
            onAction: _floorAction,
          ),
        ],
      ),
    );
  }
}
