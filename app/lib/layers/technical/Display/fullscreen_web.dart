import 'dart:js_interop';

import 'package:web/web.dart' as web;

bool get fullscreenSupported => web.document.fullscreenEnabled;

bool get isFullscreen => web.document.fullscreenElement != null;

Future<void> toggleFullscreen() async {
  if (isFullscreen) {
    await web.document.exitFullscreen().toDart;
    return;
  }
  final root = web.document.documentElement;
  if (root != null) await root.requestFullscreen().toDart;
}
