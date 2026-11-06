import 'package:flutter/widgets.dart';

const keepThreshold = 0.28;
const tearShare = 0.4;
const tearReach = 0.85;
const carouselDistance = 40.0;
const tapSlop = 12.0;
const detailIgnore = Duration(milliseconds: 450);
const phoneTableShare = 0.54;
const phoneWidth = 600.0;

enum SwipeOutcome { keep, pass, tap, none }

SwipeOutcome swipeOutcome(double dx, double width) {
  if (dx.abs() < tapSlop) return SwipeOutcome.tap;
  if (dx >= width * keepThreshold) return SwipeOutcome.keep;
  if (dx <= -width * keepThreshold) return SwipeOutcome.pass;
  return SwipeOutcome.none;
}

enum BoosterOutcome { tear, previous, next, none }

BoosterOutcome boosterOutcome(double dx, double width) {
  if (dx.abs() >= width * tearShare * tearReach) return BoosterOutcome.tear;
  if (dx > carouselDistance) return BoosterOutcome.previous;
  if (dx < -carouselDistance) return BoosterOutcome.next;
  return BoosterOutcome.none;
}

double tableHeight(Size screen) => screen.width < phoneWidth
    ? screen.height * phoneTableShare
    : screen.height * 0.6;

class ChroniclesSettings extends InheritedWidget {
  const ChroniclesSettings({
    super.key,
    required this.sound,
    required this.haptics,
    required super.child,
  });
  final bool sound, haptics;

  static ChroniclesSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChroniclesSettings>();

  @override
  bool updateShouldNotify(ChroniclesSettings old) =>
      sound != old.sound || haptics != old.haptics;
}
