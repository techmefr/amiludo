import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_background.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_contrast.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_manifest.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_layer.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_presets.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_frame.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const _aa = 4.5;
const _keep = .95;
const _modes = [Brightness.light, Brightness.dark];
const _skins = ['clean', 'play', 'cyber', 'orbital', 'paper', 'game'];

double _worst(ThemeData theme, AuraPreset? preset, Color base, Color ink) =>
    auraWorstRatio(
      preset: preset!,
      dark: theme.brightness == Brightness.dark,
      scheme: theme.colorScheme,
      base: base,
      ink: ink,
    );

void main() {
  group('aura contrast', () {
    for (final skin in _skins) {
      test('skin $skin keeps text AA on every palette and mode', () {
        for (final palette in Appearance.palettes) {
          for (final mode in _modes) {
            final theme = deckTheme(
              Appearance(skin: skin, palette: palette),
              mode,
            );
            final base = theme.scaffoldBackgroundColor;
            for (final ink in [
              theme.colorScheme.onSurface,
              theme.colorScheme.onSurfaceVariant,
            ]) {
              final text = Color.alphaBlend(ink, base);
              final baseline = auraRatio(text, base);
              final ratio = _worst(theme, AuraPresets.skin(skin), base, text);
              expect(
                ratio,
                greaterThanOrEqualTo(math.min(_aa, baseline * _keep)),
                reason: '$skin $palette $mode base $baseline',
              );
            }
          }
        }
      });
    }

    test('every tool shelf keeps text AA behind its tools', () {
      for (final MapEntry(key: shelf, value: tools) in auraShelfTools.entries) {
        for (final skin in _skins) {
          for (final mode in _modes) {
            final theme = deckTheme(Appearance(skin: skin), mode);
            for (final id in tools) {
              final ratio = _worst(
                theme,
                AuraPresets.shelf(shelf),
                toolFrameBackground(theme, toolThemeFor(id)),
                theme.colorScheme.onSurface,
              );
              expect(ratio, greaterThanOrEqualTo(_aa), reason: '$shelf $id');
            }
          }
        }
      }
    });
  });

  group('aura manifest', () {
    test('mirrors the tool shelves and covers every skin', () {
      for (final shelf in toolShelves) {
        expect(
          auraShelfTools[shelf.id]!.toSet().containsAll(shelf.tools),
          isTrue,
          reason: shelf.id,
        );
      }
      expect(auraShelfColors.keys.toSet(), auraShelfTools.keys.toSet());
      expect(auraSkins.keys.toSet(), _skins.toSet());
    });

    test('shelf identities follow the brief', () {
      expect(AuraPresets.shelfOf('dice'), 'chance');
      expect(AuraPresets.shelfOf('hourglass'), 'time');
      expect(AuraPresets.shelfOf('scores'), 'scores');
      expect(AuraPresets.shelfOf('deck'), 'cards');
      expect(AuraPresets.shelfOf('rules'), 'rules');
      expect(AuraPresets.shelfOf('combat'), 'gm');
      expect(AuraPresets.tool('unknown', 'play'), AuraPresets.skin('play'));
    });
  });

  group('aura widget', () {
    for (final size in const [
      Size(375, 812),
      Size(768, 1024),
      Size(1280, 720),
    ]) {
      testWidgets('paints cached and without overflow at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: deckTheme(const Appearance(skin: 'cyber'), Brightness.dark),
            home: const Scaffold(
              body: Stack(children: [Positioned.fill(child: AuraBackground())]),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(
          find.descendant(
            of: find.byType(AuraBackground),
            matching: find.byType(RepaintBoundary),
          ),
          findsAtLeastNWidgets(2),
        );
        expect(tester.getSize(find.byType(AuraBackground)), size);
      });
    }

    testWidgets('drift stays off under reduced motion and when hidden', (
      tester,
    ) async {
      Widget host({required bool reduced, required bool visible}) =>
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            ),
            home: TickerMode(
              enabled: visible,
              child: const Stack(
                children: [Positioned.fill(child: AuraBackground())],
              ),
            ),
          );
      await tester.pumpWidget(host(reduced: false, visible: true));
      await tester.pump(auraDriftStep);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(host(reduced: true, visible: true));
      await tester.pump(auraDriftStep);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(host(reduced: false, visible: false));
      await tester.pump(auraDriftStep);
      await tester.pump(auraDriftStep);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
