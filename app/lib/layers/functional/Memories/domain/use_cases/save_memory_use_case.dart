import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';

class SaveMemoryUseCase {
  SaveMemoryUseCase(this._memories);

  final MemoriesGateway _memories;

  Future<void> call(GameMemory memory) =>
      _memories.save(_memories.current.withMemory(memory));
}
