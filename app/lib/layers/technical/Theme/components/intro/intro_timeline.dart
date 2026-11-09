import 'package:flutter/animation.dart';

abstract final class IntroTimeline {
  static const Duration total = Duration(milliseconds: 5000);
  static const Duration skipRun = Duration(milliseconds: 700);
  static const double _span = 5000;

  static const Curve expoOut = Cubic(.16, 1, .3, 1);
  static const Curve expoIn = Cubic(.7, 0, .84, 0);
  static const Curve quartIn = Cubic(.755, .05, .855, .06);
  static const Curve expoInOut = Cubic(.87, 0, .13, 1);

  static const double sweepEnd = 700;
  static const double piecesStart = 500;
  static const double piecesEnd = 1400;
  static const double thumpEnd = 1750;
  static const double glowEnd = 1900;
  static const double wordsStart = 1900;
  static const double wordGap = 650;
  static const double wordEnter = 550;
  static const double wordExit = 450;
  static const double zoomStart = 3900;
  static const double zoomEnd = 4800;
  static const double revealEnd = 5000;

  static double get skipTo => zoomStart / _span;

  static double span(
    double t,
    double from,
    double to, [
    Curve curve = Curves.linear,
  ]) => curve.transform(((t * _span - from) / (to - from)).clamp(0.0, 1.0));

  static double wordEnterStart(int index) => wordsStart + wordGap * index;

  static double wordExitStart(int index, int count) =>
      index == count - 1 ? zoomStart - 100 : wordEnterStart(index + 1);
}
