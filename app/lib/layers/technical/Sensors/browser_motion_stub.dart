abstract final class BrowserMotion {
  static bool get supported => false;
  static bool get needsPermission => false;
  static Future<bool> requestPermission() async => false;
  static Stream<(double, double, double)> samples() => const Stream.empty();
}
