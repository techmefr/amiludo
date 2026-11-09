double packSpan(double t, double from, double to) =>
    ((t - from) / (to - from)).clamp(0.0, 1.0);

abstract final class PackBeat {
  static const double shakeEnd = .4;
  static const double tearEnd = .52;
  static const double burstStart = .42;
  static const double burstEnd = .78;
  static const double fanStart = .55;
  static const double packGone = .62;
}
