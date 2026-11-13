import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_add_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_look_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_history_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_result_view.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_surface_picker.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Network/link_share.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DiceTrayFill extends StatelessWidget {
  const DiceTrayFill({
    super.key,
    required this.session,
    required this.stage,
    required this.solid,
    required this.skin,
    required this.table,
    required this.mode,
    required this.onThrow,
    required this.onConfigure,
    required this.onView,
    required this.onSurface,
    required this.onSkin,
    required this.onTable,
    required this.onMode,
    required this.onClear,
    this.onFavorite,
    this.showShakeHint = false,
    this.motionButton,
    this.onDesigns,
    this.onMarket,
  });
  final DiceTraySession session;
  final Widget stage;
  final bool solid, showShakeHint;
  final String skin, table;
  final TrayResultMode mode;
  final VoidCallback onThrow, onClear;
  final ValueChanged<DiceTraySettings> onConfigure;
  final ValueChanged<bool> onView;
  final ValueChanged<String> onSurface, onSkin, onTable;
  final ValueChanged<TrayResultMode> onMode;
  final ValueChanged<String>? onFavorite;
  final Widget? motionButton;
  final VoidCallback? onDesigns, onMarket;

  void openConfigure(BuildContext context) => showDeckSheet<void>(
    context: context,
    title: context.l10n.diceConfigure,
    builder: (sheet) => _ConfigureList(
      session: session,
      solid: solid,
      onView: (value) {
        Navigator.pop(sheet);
        onView(value);
      },
      onSurface: (name) {
        Navigator.pop(sheet);
        onSurface(name);
      },
      onAdd: () {
        Navigator.pop(sheet);
        showDiceAddSheet(
          context,
          session.settings,
          onConfigure,
          onFavorite: onFavorite,
        );
      },
      onLook: () {
        Navigator.pop(sheet);
        showDiceLookSheet(
          context,
          skin: skin,
          table: table,
          onSkin: onSkin,
          onTable: onTable,
        );
      },
      onClear: () {
        Navigator.pop(sheet);
        onClear();
      },
      onDesigns: onDesigns == null
          ? null
          : () {
              Navigator.pop(sheet);
              onDesigns!();
            },
      onMarket: onMarket == null
          ? null
          : () {
              Navigator.pop(sheet);
              onMarket!();
            },
      onHistory: () {
        Navigator.pop(sheet);
        showTrayHistorySheet(context, session);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final empty = session.settings.dice.isEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        stage,
        TopBarSlot(
          actions: [
            IconButton(
              tooltip: l.diceConfigure,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(Targets.minimum),
              ),
              onPressed: () => openConfigure(context),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        if (motionButton != null)
          Align(alignment: Alignment.topCenter, child: motionButton),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: LayoutBuilder(
              builder: (context, box) => FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: math.min(420, box.maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface
                              .withValues(alpha: .82),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Space.sm),
                          child: TrayResultView(
                            session: session,
                            mode: mode,
                            onMode: onMode,
                          ),
                        ),
                      ),
                      if (showShakeHint && !empty)
                        Padding(
                          padding: const EdgeInsets.only(top: Space.xs),
                          child: Text(
                            l.diceTrayShakeHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: Space.sm),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(Targets.minimum),
                        ),
                        onPressed: empty ? null : onThrow,
                        icon: const Icon(Icons.casino_outlined),
                        label: Text(l.diceTrayThrow),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfigureList extends StatelessWidget {
  const _ConfigureList({
    required this.session,
    required this.solid,
    required this.onView,
    required this.onSurface,
    required this.onAdd,
    required this.onLook,
    required this.onClear,
    required this.onHistory,
    this.onDesigns,
    this.onMarket,
  });
  final VoidCallback? onDesigns, onMarket;
  final DiceTraySession session;
  final bool solid;
  final ValueChanged<bool> onView;
  final ValueChanged<String> onSurface;
  final VoidCallback onAdd, onLook, onClear, onHistory;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final thrown = session.thrown;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l.diceTrayView2d)),
            ButtonSegment(value: true, label: Text(l.diceTrayView3d)),
          ],
          selected: {solid},
          onSelectionChanged: (v) => onView(v.first),
        ),
        const SizedBox(height: Space.md),
        if (!solid) ...[
          TraySurfacePicker(
            value: SurfaceMaterial.parse(session.settings.surface).name,
            onChanged: onSurface,
          ),
          const SizedBox(height: Space.md),
        ],
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(l.diceAddRemove),
          subtitle: Text(l.diceTrayCount(session.settings.dice.length)),
          onTap: onAdd,
        ),
        if (onDesigns != null)
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l.diceCreateEdit),
            onTap: onDesigns,
          ),
        if (onMarket != null)
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: Text(l.diceFromMarket),
            onTap: onMarket,
          ),
        if (solid)
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l.diceLook),
            onTap: onLook,
          ),
        ListTile(
          leading: const Icon(Icons.history),
          title: Text(l.diceTrayHistory),
          enabled: session.history.isNotEmpty,
          onTap: onHistory,
        ),
        ListTile(
          leading: const Icon(Icons.ios_share),
          title: Text(l.diceTrayShareResult),
          enabled: thrown,
          onTap: () {
            Navigator.pop(context);
            shareLink(
              trayResultText(
                TrayResultMode.combined,
                session,
                oddEven: (odd, even) => '',
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.backspace_outlined),
          title: Text(l.diceTrayErase),
          enabled: thrown,
          onTap: onClear,
        ),
      ],
    );
  }
}
