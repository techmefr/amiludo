class ImportedGame {
  const ImportedGame({
    required this.name,
    this.imageUrl = '',
    this.minPlayers = 0,
    this.maxPlayers = 0,
    this.minutes = 0,
  });

  final String name, imageUrl;
  final int minPlayers, maxPlayers, minutes;
}
