enum PlaylistRepeat { off, all, one }

class PlaylistState {
  const PlaylistState({
    this.entryIds = const [],
    this.shuffle = false,
    this.repeat = PlaylistRepeat.off,
    this.fadeSeconds = 0,
  });

  factory PlaylistState.fromJson(Map<String, dynamic> j) => PlaylistState(
    entryIds: [
      for (final id in j['entryIds'] as List? ?? const [])
        if (id is String) id,
    ],
    shuffle: j['shuffle'] as bool? ?? false,
    repeat:
        PlaylistRepeat.values.asNameMap()[j['repeat']] ?? PlaylistRepeat.off,
    fadeSeconds: ((j['fadeSeconds'] as num?) ?? 0).toDouble().clamp(0.0, 30.0),
  );

  final List<String> entryIds;
  final bool shuffle;
  final PlaylistRepeat repeat;
  final double fadeSeconds;

  PlaylistState copyWith({
    List<String>? entryIds,
    bool? shuffle,
    PlaylistRepeat? repeat,
    double? fadeSeconds,
  }) => PlaylistState(
    entryIds: entryIds ?? this.entryIds,
    shuffle: shuffle ?? this.shuffle,
    repeat: repeat ?? this.repeat,
    fadeSeconds: fadeSeconds ?? this.fadeSeconds,
  );

  Map<String, Object?> toJson() => {
    'entryIds': entryIds,
    'shuffle': shuffle,
    'repeat': repeat.name,
    'fadeSeconds': fadeSeconds,
  };
}
