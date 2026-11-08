import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';

class LibraryStats {
  const LibraryStats({this.played = const {}, this.neverPlayed = const {}});

  final Set<String> played, neverPlayed;

  factory LibraryStats.of(
    List<ShelfGame> games,
    Iterable<({String title, String? packId})> sessions,
  ) {
    final titles = {for (final s in sessions) s.title.toLowerCase()};
    final packs = {for (final s in sessions) ?s.packId};
    final played = {
      for (final g in games)
        if (titles.contains(g.name.toLowerCase()) ||
            g.templateIds.any(packs.contains))
          g.id,
    };
    return LibraryStats(
      played: played,
      neverPlayed: {
        for (final g in games)
          if (!played.contains(g.id)) g.id,
      },
    );
  }
}
