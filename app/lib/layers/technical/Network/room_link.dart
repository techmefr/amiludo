import 'package:amiludo/layers/technical/Network/room_code.dart';

enum RoomKind { join, evening }

class RoomLink {
  const RoomLink(this.kind, this.code, {this.lan});

  static const scheme = 'amiludo';
  static const host = 'amiludo.app';
  static const webBase = String.fromEnvironment('AMILUDO_LINK_BASE');

  final RoomKind kind;
  final String code;
  final String? lan;

  Uri get appUri => Uri(
    scheme: scheme,
    host: host,
    path: '/${kind.name}/$code',
    queryParameters: lan == null ? null : {'lan': lan},
  );

  Uri get shareUri => webBase.isEmpty || lan != null
      ? appUri
      : Uri.parse('$webBase/${kind.name}/$code');

  String get route => lan == null
      ? '/${kind.name}/$code'
      : '/${kind.name}/$code?lan=${Uri.encodeQueryComponent(lan!)}';

  static RoomLink? parse(String input, {RoomKind fallback = RoomKind.join}) {
    final text = input.trim();
    final direct = normalizeRoomCode(text);
    if (direct != null && !text.contains('/')) {
      return RoomLink(direct.length == 8 ? RoomKind.evening : fallback, direct);
    }
    final full = Uri.tryParse(text);
    if (full == null) return null;
    final uri = full.fragment.startsWith('/')
        ? Uri.tryParse(full.fragment) ?? full
        : full;
    final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return null;
    final kind = RoomKind.values.where(
      (k) => k.name == parts[parts.length - 2],
    );
    final code = normalizeRoomCode(parts.last);
    if (kind.isEmpty || code == null) return null;
    final lan = uri.queryParameters['lan'];
    return RoomLink(kind.first, code, lan: _validLan(lan) ? lan : null);
  }

  static bool _validLan(String? lan) {
    final match = RegExp(r'^(\d{1,3})\.(\d{1,3})\.\d{1,3}\.\d{1,3}:\d{2,5}$')
        .firstMatch(lan ?? '');
    if (match == null) return false;
    final first = int.parse(match[1]!);
    final second = int.parse(match[2]!);
    return first == 10 ||
        first == 127 ||
        (first == 192 && second == 168) ||
        (first == 172 && second >= 16 && second <= 31);
  }
}
