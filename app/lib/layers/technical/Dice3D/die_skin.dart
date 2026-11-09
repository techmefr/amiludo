import 'dart:ui';

enum DieFinish { gloss, matte, soft, metal, wood, crystal, glass }

class DieSkin {
  const DieSkin(this.id, this.base, this.pip, this.finish);

  final String id;
  final Color base, pip;
  final DieFinish finish;

  bool get translucent =>
      finish == DieFinish.crystal || finish == DieFinish.glass;

  static const classic = DieSkin(
    'classic',
    Color(0xFFF4F1EA),
    Color(0xFFC62828),
    DieFinish.gloss,
  );

  static const all = [
    classic,
    DieSkin('matte', Color(0xFF1E1E22), Color(0xFFF2F2F2), DieFinish.matte),
    DieSkin('gold', Color(0xFFD4A52A), Color(0xFF5A3D00), DieFinish.metal),
    DieSkin('wood', Color(0xFF9C6B3F), Color(0xFF2E1A0A), DieFinish.wood),
    DieSkin('crystal', Color(0xFF8FD3F4), Color(0xFF0B3A5B), DieFinish.crystal),
    DieSkin('glass', Color(0xFFCFE8E0), Color(0xFF1F4D43), DieFinish.glass),
    DieSkin('cream', Color(0xFFF0E4D4), Color(0xFF2E2825), DieFinish.soft),
    DieSkin('violet', Color(0xFF9B3BE8), Color(0xFF2A2230), DieFinish.soft),
  ];

  static DieSkin byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => classic);
}
