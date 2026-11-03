import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';

class EveningAgenda {
  const EveningAgenda({this.evenings = const []});

  final List<Evening> evenings;

  Map<String, Object?> toJson() => {
    'evenings': evenings.map((e) => e.toJson()).toList(),
  };

  factory EveningAgenda.fromJson(Map<String, dynamic> j) => EveningAgenda(
    evenings: (j['evenings'] as List? ?? const [])
        .map((e) => Evening.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}
