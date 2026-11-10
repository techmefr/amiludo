import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_flip.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_customization.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/functional/Random/presentation/count_stepper.dart';
import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_focus.dart';

const int maxCoins = 6;

class CoinTool extends StatefulWidget {
  const CoinTool({
    super.key,
    this.random,
    this.motion = const NoTrayMotion(),
    this.haptics = false,
  });
  final RandomTools? random;
  final TrayMotion motion;
  final bool haptics;
  @override
  State<CoinTool> createState() => _CoinToolState();
}

class _CoinToolState extends State<CoinTool> {
  late final RandomTools random = widget.random ?? RandomTools();
  StreamSubscription<double>? throws;
  int count = 1, flipId = 0, landed = 0;
  List<bool> results = [];
  DieDesign? customized;
  late final DieDesign? stored = DieStudio.maybeOf(context)?.state
      .byId(coinDesignId);

  DieDesign get design =>
      customized ?? (stored?.sides == 2 ? stored! : defaultCoin(context));

  Future<void> editFace(int side) async {
    final edited = await customizeCoin(context, design, side);
    if (mounted && edited != null) setState(() => customized = edited);
  }

  @override
  void initState() {
    super.initState();
    throws = widget.motion.throws.listen(
      (_) => flip(),
      onError: (Object _) {},
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    throws?.cancel();
    super.dispose();
  }

  bool get flying => results.isNotEmpty && landed < results.length;

  void flip() {
    if (flying || !mounted) return;
    setState(() {
      flipId++;
      landed = 0;
      results = [for (var i = 0; i < count; i++) random.integer(0, 1) == 1];
    });
  }

  void land() {
    if (widget.haptics) unawaited(DeckHaptics.impact());
    setState(() => landed++);
  }

  void setCount(int value) => setState(() {
    count = value;
    results = [];
    landed = 0;
  });

  String summary(BuildContext context) {
    if (results.isEmpty || flying) return '';
    final front = coinSideLabel(context, design, 0);
    final back = coinSideLabel(context, design, 1);
    if (results.length == 1) return results.first ? front : back;
    final heads = results.where((r) => r).length;
    return '$heads × $front · ${results.length - heads} × $back';
  }

  Widget stage(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final scheme = Theme.of(context).colorScheme;
      final window = MediaQuery.sizeOf(context);
      final height = (window.height * (window.height < 520 ? .48 : .52)).clamp(
        140.0,
        560.0,
      );
      final columns = math.min(
        count,
        math.max(1, (box.maxWidth / 100).floor()),
      );
      final rows = (count / columns).ceil();
      final rowHeight = (height - (rows - 1) * Space.xs) / rows;
      final cellWidth = (box.maxWidth - (columns - 1) * Space.md) / columns;
      final size = math.min(
        math.min(cellWidth, rowHeight * .76),
        170 * ToolStage.factor(context),
      );
      return GestureDetector(
        onTap: flip,
        child: Semantics(
          button: true,
          label: context.l10n.toolCoinTitle,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.end,
              runAlignment: WrapAlignment.center,
              spacing: Space.md,
              runSpacing: Space.xs,
              children: [
                for (var i = 0; i < count; i++)
                  CoinFlip(
                    key: ValueKey('coin-$i'),
                    heads: i < results.length ? results[i] : null,
                    flipId: flipId,
                    size: size,
                    height: rowHeight,
                    front: customCoinFace(design, 0),
                    back: customCoinFace(design, 1),
                    onLanded: land,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = summary(context);
    final edit = CoinFaceMenu(
      design: design,
      onSelect: flying ? null : editFace,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (DieStudio.maybeOf(context) != null)
          TopBarSlot(
            actions: [edit],
            fallback: Align(alignment: Alignment.centerRight, child: edit),
          ),
        CountStepper(
          label: l.coinCount,
          value: count,
          minimum: 1,
          maximum: maxCoins,
          lessTooltip: l.coinFewer,
          moreTooltip: l.coinMore,
          onChanged: flying ? (_) {} : setCount,
        ),
        const SizedBox(height: Space.md),
        stage(context),
        SizedBox(
          height: Space.xxl * 4,
          child: text.isEmpty
              ? Center(
                  child: Text(
                    results.isEmpty ? l.randomPressTheButtonToRoll : '',
                    textAlign: TextAlign.center,
                  ),
                )
              : ToolResultText(text: text, compact: results.length > 1),
        ),
        ToolPrimaryButton(
          onPressed: flying ? null : flip,
          label: l.coinFlip,
          icon: Icons.toll_outlined,
        ),
      ],
    );
  }
}
