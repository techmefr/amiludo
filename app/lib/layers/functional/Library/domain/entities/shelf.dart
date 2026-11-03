import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';

class Shelf {
  const Shelf({this.games = const []});

  final List<ShelfGame> games;

  Map<String, Object?> toJson() => {
    'shelf': games.map((g) => g.toJson()).toList(),
  };

  factory Shelf.fromJson(Map<String, dynamic> j) => Shelf(
    games: (j['shelf'] as List? ?? const [])
        .map((g) => ShelfGame.fromJson(Map<String, dynamic>.from(g as Map)))
        .toList(),
  );
}
