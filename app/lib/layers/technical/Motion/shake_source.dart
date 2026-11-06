import 'dart:async';

abstract class ShakeSource {
  Stream<void> get shakes;
}

class NoShakeSource implements ShakeSource {
  const NoShakeSource();

  @override
  Stream<void> get shakes => const Stream.empty();
}

class ManualShakeSource implements ShakeSource {
  final _controller = StreamController<void>.broadcast();

  @override
  Stream<void> get shakes => _controller.stream;

  void shake() => _controller.add(null);

  Future<void> close() => _controller.close();
}
