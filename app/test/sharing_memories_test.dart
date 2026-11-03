import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/set_resource_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/set_status_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/start_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/add_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/export_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/import_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/save_memory_use_case.dart';
import 'package:amiludo/layers/functional/Sharing/domain/entities/session_bundle.dart';
import 'package:amiludo/layers/functional/Sharing/domain/use_cases/build_session_bundle_use_case.dart';
import 'package:amiludo/layers/functional/Sharing/domain/use_cases/import_session_bundle_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/technical/Transfer/compression.dart';

import 'fakes.dart';

const heroes = GameTemplate(
  id: 'custom-heroes',
  name: 'Héros',
  resources: {'Vies': 50, 'Combat': 2},
  statuses: ['Poison', 'Bouclier'],
);

final session = GameSession(
  id: 'night',
  title: 'Soirée',
  players: const [Player(id: 'a', name: 'Camille', color: 0)],
  createdAt: 1,
);

void main() {
  _sharingTests();
  _trackerTests();
  _galleryTests();
}

void _sharingTests() {
  test(
    'a session bundle carries the shelf game, its pack and sheets',
    () async {
      final senderShelf = MemoryShelf(
        const Shelf(
          games: [
            ShelfGame(
              id: 'dt',
              name: 'Dice Throne',
              templateIds: ['custom-heroes', 'free'],
            ),
          ],
        ),
      );
      final sender = MemoryWorkspace(
        Workspace(
          templates: const [heroes],
          characters: [
            GameCharacter(
              id: 'c1',
              name: 'Barbare',
              packName: 'Héros',
              createdAt: 1,
              choices: {},
            ),
            GameCharacter(
              id: 'c2',
              name: 'Autre',
              packName: 'Autre',
              createdAt: 1,
              choices: {},
            ),
          ],
        ),
      );
      final bundle = BuildSessionBundleUseCase(sender, senderShelf)(
        shelfGameIds: ['dt'],
      );
      final travelled = SessionBundle.fromJson(
        Map<String, dynamic>.from(
          unpackJson(packJson(bundle.toJson()))! as Map,
        ),
      );
      expect(travelled.templates.map((t) => t.id), ['custom-heroes', 'free']);
      expect(travelled.characters.map((c) => c.id), ['c1']);
      final receiver = MemoryWorkspace(
        const Workspace(
          templates: [GameTemplate(id: 'custom-heroes', name: 'Old')],
        ),
      );
      final receiverShelf = MemoryShelf();
      final receive = ImportSessionBundleUseCase(receiver, receiverShelf);
      final result = await receive(travelled);
      expect(result.templates, 1);
      expect(receiver.current.templates.single.name, 'Héros');
      expect(receiverShelf.current.games.single.name, 'Dice Throne');
      await receive(travelled);
      expect(receiverShelf.current.games, hasLength(1));
      expect(receiver.current.characters, hasLength(1));
    },
  );

  test('foreign json is not a session bundle', () {
    expect(
      () => SessionBundle.fromJson({'format': 'other', 'version': 1}),
      throwsFormatException,
    );
  });
}

void _trackerTests() {
  test('pack trackers start the game and stack statuses', () async {
    final gateway = MemoryWorkspace();
    await StartGameUseCase(gateway, MonotonicTime())('', ['Camille'], heroes);
    final player = gateway.current.current!.players.single;
    expect(player.resources, {'Vies': 50, 'Combat': 2});
    await SetResourceUseCase(gateway)(player.id, 'Vies', 47);
    await SetStatusUseCase(gateway)(player.id, 'Poison', 2);
    await SetStatusUseCase(gateway)(player.id, 'Bouclier', 1);
    await SetStatusUseCase(gateway)(player.id, 'Bouclier', 0);
    final updated = gateway.current.current!.players.single;
    expect(updated.resources['Vies'], 47);
    expect(updated.statuses, {'Poison': 2});
    final reloaded = Player.fromJson(updated.toJson());
    expect(reloaded.statuses, {'Poison': 2});
    expect(GameTemplate.fromJson(heroes.toJson()).statuses, heroes.statuses);
  });

  test('invalid pack trackers are rejected', () {
    final json = heroes.toJson()..['statuses'] = ['Poison', 'Poison'];
    expect(() => GameTemplate.fromJson(json), throwsFormatException);
  });
}

void _galleryTests() {
  test('an encrypted gallery travels with its key only', () async {
    final photos = MemoryPhotos();
    final sender = MemoryWorkspace(Workspace(games: [session]));
    await AddPhotoUseCase(sender, photos)('night', [1, 2, 3]);
    await SaveMemoryUseCase(sender)(
      sender.current
          .memoryOf('night')
          .copyWith(
            note: 'Quelle soirée',
            highlights: const [Highlight(id: 'h', text: 'Triple six', at: 2)],
          ),
    );
    final export = await ExportGalleryUseCase(sender, photos)(
      'night',
      sender.current.memoryOf('night').photoIds,
    );
    final receivedPhotos = MemoryPhotos();
    final receiver = MemoryWorkspace();
    final import = ImportGalleryUseCase(receiver, receivedPhotos);
    await expectLater(
      import(export.fileText, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='),
      throwsFormatException,
    );
    expect(await import(export.fileText, export.key), 'night');
    final memory = receiver.current.memoryOf('night');
    expect(receiver.current.games.single.title, 'Soirée');
    expect(memory.note, 'Quelle soirée');
    expect(memory.highlights.single.text, 'Triple six');
    expect(receivedPhotos.stored.values.single, [1, 2, 3]);
  });
}
