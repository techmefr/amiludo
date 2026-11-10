import 'dart:ui';

Rect mirrorRect(Rect r) => Rect.fromLTWH(1 - r.right, r.top, r.width, r.height);

Rect fitRect(Rect box, Rect target) {
  final scale = target.width / box.width < target.height / box.height
      ? target.width / box.width
      : target.height / box.height;
  final left = target.center.dx - box.center.dx * scale;
  final top = target.center.dy - box.center.dy * scale;
  return Rect.fromLTWH(left, top, scale, scale);
}
