import 'package:amiludo/layers/functional/Sounds/domain/entities/playlist_state.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';

const maxSoundEntries = 100;
const soundSetVersion = 1;

enum SoundOwnerKind { companion, campaign, game }

String newSoundId() => DateTime.now().microsecondsSinceEpoch.toString();

class SoundSet {
  const SoundSet({
    required this.id,
    required this.name,
    required this.ownerKind,
    required this.ownerId,
    this.entries = const [],
    this.playlist = const PlaylistState(),
    this.soundboard = const [],
    this.playlistVolume = 1,
    this.soundboardVolume = 1,
  });

  factory SoundSet.fromJson(Map<String, dynamic> j) {
    final playlist = j['playlist'];
    return SoundSet(
      id: j['id'] as String,
      name: j['name'] as String? ?? '',
      ownerKind:
          SoundOwnerKind.values.asNameMap()[j['ownerKind']] ??
          SoundOwnerKind.companion,
      ownerId: j['ownerId'] as String? ?? '',
      entries: [
        for (final e in j['entries'] as List? ?? const [])
          if (e is Map) SoundEntry.fromJson(Map<String, dynamic>.from(e)),
      ].take(maxSoundEntries).toList(),
      playlist: playlist is Map
          ? PlaylistState.fromJson(Map<String, dynamic>.from(playlist))
          : const PlaylistState(),
      soundboard: [
        for (final id in j['soundboard'] as List? ?? const [])
          if (id is String) id,
      ],
      playlistVolume: ((j['playlistVolume'] as num?) ?? 1).toDouble().clamp(
        0.0,
        1.0,
      ),
      soundboardVolume: ((j['soundboardVolume'] as num?) ?? 1).toDouble().clamp(
        0.0,
        1.0,
      ),
    );
  }

  final String id, name, ownerId;
  final SoundOwnerKind ownerKind;
  final List<SoundEntry> entries;
  final PlaylistState playlist;
  final List<String> soundboard;
  final double playlistVolume, soundboardVolume;

  bool get isFull => entries.length >= maxSoundEntries;

  SoundEntry? entry(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  SoundSet copyWith({
    String? name,
    List<SoundEntry>? entries,
    PlaylistState? playlist,
    List<String>? soundboard,
    double? playlistVolume,
    double? soundboardVolume,
  }) => SoundSet(
    id: id,
    name: name ?? this.name,
    ownerKind: ownerKind,
    ownerId: ownerId,
    entries: entries ?? this.entries,
    playlist: playlist ?? this.playlist,
    soundboard: soundboard ?? this.soundboard,
    playlistVolume: playlistVolume ?? this.playlistVolume,
    soundboardVolume: soundboardVolume ?? this.soundboardVolume,
  );

  Map<String, Object?> toJson() => {
    'version': soundSetVersion,
    'id': id,
    'name': name,
    'ownerKind': ownerKind.name,
    'ownerId': ownerId,
    'entries': [for (final e in entries) e.toJson()],
    'playlist': playlist.toJson(),
    'soundboard': soundboard,
    'playlistVolume': playlistVolume,
    'soundboardVolume': soundboardVolume,
  };
}

class SoundLibrary {
  const SoundLibrary([this.sets = const []]);

  factory SoundLibrary.fromJson(Map<String, dynamic> j) => SoundLibrary([
    for (final s in j['sets'] as List? ?? const [])
      if (s is Map) SoundSet.fromJson(Map<String, dynamic>.from(s)),
  ]);

  final List<SoundSet> sets;

  bool get isEmpty => sets.isEmpty;

  List<SoundSet> ownedBy(SoundOwnerKind kind, String ownerId) => [
    for (final s in sets)
      if (s.ownerKind == kind && s.ownerId == ownerId) s,
  ];

  Map<String, Object?> toJson() => {
    'sets': [for (final s in sets) s.toJson()],
  };
}
