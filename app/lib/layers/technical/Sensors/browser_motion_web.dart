import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

abstract final class BrowserMotion {
  static bool _authorized = false;

  static JSObject? get _constructor =>
      globalContext.getProperty<JSObject?>('DeviceMotionEvent'.toJS);

  static bool get supported =>
      web.window.isSecureContext &&
      web.window.navigator.maxTouchPoints > 0 &&
      _constructor != null;

  static bool get needsPermission {
    if (!supported || _authorized) return false;
    final method = _constructor?.getProperty<JSAny?>('requestPermission'.toJS);
    return method != null && method.typeofEquals('function');
  }

  static Future<bool> requestPermission() async {
    if (!supported) return false;
    if (!needsPermission) return true;
    try {
      final result = await _constructor!
          .callMethod<JSPromise<JSString>>('requestPermission'.toJS)
          .toDart;
      return _authorized = result.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  static Stream<(double, double, double)> samples() {
    if (!supported || needsPermission) return const Stream.empty();
    late final StreamController<(double, double, double)> controller;
    final listener = ((web.DeviceMotionEvent event) {
      final reading = event.accelerationIncludingGravity;
      final x = reading?.x, y = reading?.y, z = reading?.z;
      if (x != null &&
          y != null &&
          z != null &&
          x.isFinite &&
          y.isFinite &&
          z.isFinite &&
          x * x + y * y + z * z > 1) {
        controller.add((x, y, z));
      }
    }).toJS;
    controller = StreamController(
      onListen: () => web.window.addEventListener('devicemotion', listener),
      onCancel: () => web.window.removeEventListener('devicemotion', listener),
    );
    return controller.stream;
  }
}
