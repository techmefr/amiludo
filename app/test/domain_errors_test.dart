import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_friend_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/start_game_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/add_photo_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_state.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';

import 'fakes.dart';

void main() {
  test('a friend with the same name is a typed duplicate', () async {
    final workspace = MemoryWorkspace();
    await SaveFriendUseCase(workspace)(const Friend(id: 'a', name: 'Léa'));
    expect(
      () => SaveFriendUseCase(workspace)(const Friend(id: 'b', name: ' léa ')),
      throwsA(FriendError.duplicate),
    );
  });

  test('a game needs distinct names', () {
    final start = StartGameUseCase(MemoryWorkspace(), MonotonicTime());
    final template = GameTemplate.builtIn.first;
    expect(
      () => start('', const [], template),
      throwsA(GameError.invalidPlayers),
    );
    expect(
      () => start('', const ['Léa', 'Léa'], template),
      throwsA(GameError.invalidPlayers),
    );
  });

  test('photos are limited in size and count', () async {
    final photos = MemoryPhotos();
    final add = AddPhotoUseCase(MemoryWorkspace(), photos);
    expect(
      () => add('night', List.filled(AddPhotoUseCase.maxBytes + 1, 0)),
      throwsA(PhotoError.tooLarge),
    );
    final full = MemoryWorkspace(
      const Workspace().withMemory(
        GameMemory(
          sessionId: 'night',
          photoIds: [for (var i = 0; i < AddPhotoUseCase.maxPhotos; i++) '$i'],
        ),
      ),
    );
    expect(
      () => AddPhotoUseCase(full, photos)('night', const [1]),
      throwsA(PhotoError.tooMany),
    );
  });

  test('pack filters match their components', () {
    final pack = GameTemplate.builtIn.first;
    expect(PackFilter.all.matches(pack), isTrue);
    expect(PackFilter.dice.matches(pack), pack.dice.isNotEmpty);
    expect(PackFilter.roles.matches(pack), pack.roles.isNotEmpty);
    expect(PackFilter.scores.matches(pack), pack.scoring.isNotEmpty);
    expect(PackFilter.characters.matches(pack), pack.creation.isNotEmpty);
  });
}
