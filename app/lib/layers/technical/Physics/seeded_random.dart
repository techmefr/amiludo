class SeededRandom {
  SeededRandom(int seed) : _state = _mix(seed);

  int _state;

  static int _mix(int seed) {
    final folded = (seed ^ (seed >> 32)) & 0xFFFFFFFF;
    return folded == 0 ? 0x9E3779B9 : folded;
  }

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  int nextInt(int max) => _next() % max;

  double nextDouble() => _next() / 4294967296;

  double range(double low, double high) => low + nextDouble() * (high - low);
}
