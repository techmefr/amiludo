import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class PaperPalette {
  const PaperPalette._();
  static const paper = Color(0xfff1e6cf);
  static const ink = Color(0xff2b2118);
  static const seal = Color(0xffa3342b);
  static const blue = Color(0xff2f4b6e);
  static const margin = Color(0xffd8c7a3);
  static const night = Color(0xff1c1713);
  static const nightInk = Color(0xffeadfc8);
}

ThemeData paperTheme(ThemeData base, Color accent) {
  final dark = base.brightness == Brightness.dark;
  final ground = dark ? PaperPalette.night : PaperPalette.paper;
  final ink = dark ? PaperPalette.nightInk : PaperPalette.ink;
  final strip = dark ? const Color(0xff2a231c) : PaperPalette.margin;
  final readable = ToolTheme(accent: accent).ink(ground);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: accent,
        brightness: base.brightness,
      ).copyWith(
        surface: ground,
        onSurface: ink,
        onSurfaceVariant: ink.withValues(alpha: .82),
        primary: readable,
        surfaceContainerHighest: strip,
      );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: ground,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: strip,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: ink.withValues(alpha: .5))),
    ),
    tabBarTheme: base.tabBarTheme.copyWith(
      indicatorColor: PaperPalette.seal,
      labelColor: ink,
      unselectedLabelColor: ink.withValues(alpha: .75),
    ),
  );
}

class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ColoredBox(color: Theme.of(context).colorScheme.surface),
      ),
      const ToolTextureLayer(texture: ToolTexture.paper, opacity: .06),
      child,
    ],
  );
}

class _RibbonClipper extends CustomClipper<Path> {
  const _RibbonClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width / 2, size.height - size.width / 2)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_RibbonClipper old) => false;
}

class RibbonBookmark extends StatelessWidget {
  const RibbonBookmark({super.key, this.color = PaperPalette.seal});
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipPath(
      clipper: const _RibbonClipper(),
      child: SizedBox(
        width: Space.xl,
        height: Space.section,
        child: ColoredBox(color: color),
      ),
    ),
  );
}
