import 'dart:ui';

class TableTheme {
  const TableTheme(this.id, this.center, this.edge, this.rim);

  final String id;
  final Color center, edge, rim;

  static const felt = TableTheme(
    'felt',
    Color(0xFF2F8F5B),
    Color(0xFF14573A),
    Color(0xFF0C3524),
  );

  static const all = [
    felt,
    TableTheme('dark', Color(0xFF2A2D34), Color(0xFF121317), Color(0xFF0A0B0D)),
    TableTheme(
      'light',
      Color(0xFFF1EFEA),
      Color(0xFFD5D1C8),
      Color(0xFFB9B4A8),
    ),
    TableTheme('wood', Color(0xFFA8743F), Color(0xFF6B4423), Color(0xFF3F2512)),
    TableTheme('blue', Color(0xFF3F74C4), Color(0xFF1D3F7A), Color(0xFF112650)),
    TableTheme('red', Color(0xFFB23A3A), Color(0xFF6E1B1B), Color(0xFF450F0F)),
  ];

  static TableTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => felt);
}
