import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/atlas.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

NotebookCampaign _world() {
  final sea = NotebookEntry.create(EntryKind.place, 'Grey Sea');
  final isle = NotebookEntry.create(
    EntryKind.place,
    'Black Isle',
    parentId: sea.id,
  );
  final port = NotebookEntry.create(EntryKind.place, 'Port', parentId: isle.id);
  final dungeon = NotebookEntry.create(
    EntryKind.place,
    'Crypt',
    parentId: isle.id,
  );
  final npc = NotebookEntry.create(EntryKind.npc, 'Mira');
  return NotebookCampaign.create('World', CampaignKind.gm)
      .withEntry(port)
      .withEntry(dungeon)
      .withEntry(isle)
      .withEntry(sea)
      .withEntry(npc);
}

void main() {
  test('places form a tree with depths and ignore other entries', () {
    final nodes = atlasTree(_world());
    expect(
      [for (final n in nodes) (n.entry.name, n.depth)],
      [('Grey Sea', 0), ('Black Isle', 1), ('Port', 2), ('Crypt', 2)],
    );
  });

  test('a place cannot move inside its own descendants', () {
    final world = _world();
    final sea = world.entries.firstWhere((e) => e.name == 'Grey Sea');
    final port = world.entries.firstWhere((e) => e.name == 'Port');
    expect(parentCandidates(world, sea.id), isEmpty);
    final unchanged = withParent(world, sea.id, port.id);
    expect(unchanged.entry(sea.id)!.parentId, isNull);
    final moved = withParent(world, port.id, sea.id);
    expect(moved.entry(port.id)!.parentId, sea.id);
    expect(withParent(moved, port.id, null).entry(port.id)!.parentId, isNull);
  });

  test('a cycle in stored data still lists every place once', () {
    final a = NotebookEntry.create(EntryKind.place, 'A');
    final b = NotebookEntry.create(EntryKind.place, 'B', parentId: a.id);
    final looped = NotebookCampaign.create(
      'Loop',
      CampaignKind.solo,
    ).withEntry(a.copyWith(parentId: b.id)).withEntry(b);
    expect(atlasTree(looped), hasLength(2));
  });

  test(
    'pin links are set, replaced, cleared and dropped with their target',
    () {
      final world = _world();
      final isle = world.entries.firstWhere((e) => e.name == 'Black Isle');
      final npc = world.entries.firstWhere((e) => e.name == 'Mira');
      final linked = withPinLink(world, isle.id, 'p1', npc.id);
      expect(linked.pinLinks[pinKey(isle.id, 'p1')], npc.id);
      expect(withPinLink(linked, isle.id, 'p1', null).pinLinks, isEmpty);
      expect(linked.withoutEntry(npc.id).pinLinks, isEmpty);
      expect(linked.withoutEntry(isle.id).pinLinks, isEmpty);
      expect(atlasMapKey('c', 'p'), 'nb:c:p');
    },
  );
}
