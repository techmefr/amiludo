import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';

class MemoryAlbum {
  const MemoryAlbum({this.memories = const []});

  final List<GameMemory> memories;

  GameMemory memoryOf(String sessionId) => memories.firstWhere(
    (m) => m.sessionId == sessionId,
    orElse: () => GameMemory(sessionId: sessionId),
  );

  MemoryAlbum withMemory(GameMemory memory) => MemoryAlbum(
    memories: [
      memory,
      ...memories.where((m) => m.sessionId != memory.sessionId),
    ],
  );

  Map<String, Object?> toJson() => {
    'memories': memories.map((m) => m.toJson()).toList(),
  };

  factory MemoryAlbum.fromJson(Map<String, dynamic> j) => MemoryAlbum(
    memories: (j['memories'] as List? ?? const [])
        .map((m) => GameMemory.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList(),
  );
}
