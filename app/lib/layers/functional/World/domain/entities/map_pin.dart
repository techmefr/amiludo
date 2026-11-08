import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';

enum PinKind { place, npc, scene, danger }

class MapPin {
  const MapPin({
    required this.id,
    required this.kind,
    required this.point,
    required this.title,
    this.note = '',
    this.refId,
    this.childMapId,
    this.secret = false,
  });

  factory MapPin.fromJson(Map<String, dynamic> j) => MapPin(
    id: j['id'] as String? ?? newElementId(),
    kind: PinKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => PinKind.place,
    ),
    point: WorldPoint.fromJson(j['point']),
    title: j['title'] as String? ?? '',
    note: j['note'] as String? ?? '',
    refId: j['refId'] as String?,
    childMapId: j['childMapId'] as String?,
    secret: j['secret'] == true,
  );

  final String id, title, note;
  final PinKind kind;
  final WorldPoint point;
  final String? refId, childMapId;
  final bool secret;

  MapPin copyWith({
    PinKind? kind,
    WorldPoint? point,
    String? title,
    String? note,
    String? refId,
    String? childMapId,
    bool? secret,
    bool clearRef = false,
    bool clearChild = false,
  }) => MapPin(
    id: id,
    kind: kind ?? this.kind,
    point: point ?? this.point,
    title: title ?? this.title,
    note: note ?? this.note,
    refId: clearRef ? null : refId ?? this.refId,
    childMapId: clearChild ? null : childMapId ?? this.childMapId,
    secret: secret ?? this.secret,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'point': point.toJson(),
    'title': title,
    'note': note,
    'refId': refId,
    'childMapId': childMapId,
    'secret': secret,
  };
}
