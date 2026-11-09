import 'package:flutter/material.dart';

const steampunkFrameAsset = 'assets/cards/steampunk-frame.png';
const steampunkRatio = 1060 / 1484;
const steampunkInk = Color(0xff2b1a0e);
const steampunkWindow = Color(0xff3a2a1c);

class SteampunkFace extends StatelessWidget {
  const SteampunkFace({
    super.key,
    required this.title,
    this.description,
    this.art,
    this.width = 200,
  });
  final String title;
  final String? description;
  final Widget? art;
  final double width;

  Widget _zone(double s, Rect px, Widget child) => Positioned(
    left: px.left * s,
    top: px.top * s,
    width: px.width * s,
    height: px.height * s,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final s = width / 1060;
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: [title, ?description].join(', '),
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: width / steampunkRatio,
        child: Stack(
          children: [
            _zone(
              s,
              const Rect.fromLTRB(60, 205, 1000, 1005),
              ColoredBox(
                color: steampunkWindow,
                child: Center(
                  child:
                      art ??
                      Icon(
                        Icons.settings,
                        size: width * .4,
                        color: const Color(0xffd9a441),
                      ),
                ),
              ),
            ),
            Positioned.fill(
              child: Image.asset(
                steampunkFrameAsset,
                fit: BoxFit.fill,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            _zone(
              s,
              const Rect.fromLTRB(120, 100, 940, 185),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: text.titleLarge?.copyWith(
                      color: steampunkInk,
                      fontSize: 62 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            if (description != null)
              _zone(
                s,
                const Rect.fromLTRB(110, 1040, 950, 1350),
                Center(
                  child: Text(
                    description!,
                    textAlign: TextAlign.center,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: steampunkInk,
                      fontSize: 52 * s,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
