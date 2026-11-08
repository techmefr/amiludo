import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _paper = Color(0xff0F0E12);
const _ink = Color(0xffF3EBDD);

Future<void> showHandout(BuildContext context, Scene scene) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => HandoutPage(scene: scene),
      ),
    );

class HandoutPage extends StatelessWidget {
  const HandoutPage({super.key, required this.scene});
  final Scene scene;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Space.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        scene.title,
                        textAlign: TextAlign.center,
                        style: text.displaySmall?.copyWith(
                          color: _ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.xl),
                    Text(
                      scene.handout,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall?.copyWith(
                        color: _ink,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: Space.sm,
              right: Space.sm,
              child: IconButton.filledTonal(
                tooltip: l.scenesHide,
                onPressed: () => Navigator.pop(context),
                icon: const DeckIcon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
