import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/campaign_file.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/entry_links.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_search.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_wide_search.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/oracle.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

final _tables = OracleTables({
  'action': ['Gather'],
  'theme': ['Debt'],
  'descriptor': ['Fragile'],
  'aspect': ['Door'],
  'eventFocus': ['A newcomer arrives'],
  'reaction': ['Hostile', 'Wary', 'Indifferent', 'Friendly', 'Helpful'],
  'discovery': ['A hidden passage'],
  'complication': ['Time is running out'],
});

NotebookCampaign _campaign() {
  final mira = NotebookEntry.create(EntryKind.npc, 'Mira');
  final isle = NotebookEntry.create(EntryKind.place, 'Black Isle');
  final quest = NotebookEntry.create(EntryKind.quest, 'Lost lantern').copyWith(
    sections: [
      EntrySection(
        id: 'd',
        type: SectionType.description,
        text: 'Ask [[Mira]] about the lantern near black isle.',
      ),
    ],
  );
  return NotebookCampaign.create('Tides', CampaignKind.solo)
      .withEntry(mira)
      .withEntry(isle)
      .withEntry(quest)
      .withLine(
        JournalLine.create(
          JournalKind.note,
          'Met Mira on the Black Isle',
          DateTime(2026, 11, 7),
        ),
        DateTime(2026, 11, 7),
      );
}

void main() {
  test('a notebook survives a JSON round trip', () {
    final notebook = Notebook(campaigns: [_campaign().copyWith(chaos: 7)]);
    final copy = Notebook.fromJson(
      jsonDecode(jsonEncode(notebook.toJson())) as Map<String, dynamic>,
    );
    expect(jsonEncode(copy.toJson()), jsonEncode(notebook.toJson()));
    expect(copy.campaigns.single.chaos, 7);
    expect(copy.campaigns.single.activeSession!.lines, hasLength(1));
  });

  test('names and [[brackets]] become links, longest name first', () {
    final entries = [
      NotebookEntry.create(EntryKind.place, 'Isle'),
      NotebookEntry.create(EntryKind.place, 'Black Isle'),
      NotebookEntry.create(EntryKind.npc, 'Mira'),
    ];
    final segments = linkSegments(
      'Mira sails to the black isle, not Miranda. See [[Isle]] and [[Nowhere]].',
      entries,
    );
    final linked = {
      for (final s in segments)
        if (s.entryId != null) s.text: s.entryId,
    };
    expect(linked['Mira'], entries[2].id);
    expect(linked['black isle'], entries[1].id);
    expect(linked['Isle'], entries[0].id);
    expect(segments.map((s) => s.text).join(), contains('Miranda'));
    expect(segments.where((s) => s.text == 'Nowhere').single.entryId, isNull);
    expect(segments.map((s) => s.text).join(), isNot(contains('[[')));
  });

  test('text without entries stays a single plain segment', () {
    final segments = linkSegments('Nothing here', const []);
    expect(segments.single.entryId, isNull);
  });

  test('back-links list entries and journal lines that mention an entry', () {
    final campaign = _campaign();
    final mira = campaign.entries.firstWhere((e) => e.name == 'Mira');
    final found = backlinks(campaign, mira.id);
    expect(found.entries.map((e) => e.name), ['Lost lantern']);
    expect(found.lines.single, contains('Met Mira'));
  });

  test('removing an entry detaches its children and pins', () {
    final isle = NotebookEntry.create(EntryKind.place, 'Isle');
    final camp = NotebookEntry.create(
      EntryKind.place,
      'Camp',
      parentId: isle.id,
    );
    final campaign = NotebookCampaign.create('Map', CampaignKind.gm)
        .withEntry(isle)
        .withEntry(camp)
        .copyWith(pinLinks: {'${isle.id}/pin': camp.id});
    final next = campaign.withoutEntry(isle.id);
    expect(next.entries.single.parentId, isNull);
    expect(next.pinLinks, isEmpty);
  });

  test('search finds entries by section text and journal lines', () {
    final campaign = _campaign();
    final hits = searchCampaign(campaign, 'lantern');
    expect(hits.first.entry!.name, 'Lost lantern');
    expect(searchCampaign(campaign, 'met mira').single.line, isNotNull);
    expect(searchCampaign(campaign, '  '), isEmpty);
    expect(searchCampaign(campaign, 'zzz'), isEmpty);
  });

  test('search covers every campaign and keeps favourites first', () {
    final other = NotebookCampaign.create('Other', CampaignKind.gm)
        .withEntry(NotebookEntry.create(EntryKind.npc, 'Mirabel'))
        .copyWith(favorite: true);
    final found = searchNotebook(
      Notebook(campaigns: [_campaign(), other]),
      'mira',
    );
    expect(found.map((h) => h.campaign.title).toSet(), {'Tides', 'Other'});
    expect(found.first.campaign.title, 'Other');
    expect(searchNotebook(const Notebook(), 'mira'), isEmpty);
  });

  test('a campaign file imports with fresh ids and images', () {
    final base = _campaign().withLook(headerImageId: 'img1');
    final file = CampaignFile(base, {
      'img1': base64Encode([1, 2, 3]),
    });
    final decoded = CampaignFile.decode(file.encode()).fresh();
    expect(decoded.campaign.id, isNot(base.id));
    expect(decoded.campaign.headerImageId, isNot('img1'));
    expect(decoded.images.keys.single, decoded.campaign.headerImageId);
    expect(decoded.campaign.entries, hasLength(3));
    expect(decoded.campaign.favorite, isFalse);
    expect(
      () => CampaignFile.decode('{"format":"other"}'),
      throwsFormatException,
    );
    expect(() => CampaignFile.decode('nope'), throwsFormatException);
  });

  group('oracle', () {
    Oracle oracle(int seed) =>
        Oracle(_tables, random: RandomTools(random: Random(seed)));

    test('chance follows likelihood and chaos within bounds', () {
      expect(Oracle.chanceOf(Likelihood.even, defaultChaos), 50);
      expect(Oracle.chanceOf(Likelihood.even, 9), 66);
      expect(Oracle.chanceOf(Likelihood.veryUnlikely, 1), 5);
      expect(Oracle.chanceOf(Likelihood.veryLikely, 9), 95);
    });

    test('answers are deterministic for a seeded generator', () {
      final a = oracle(4).ask(Likelihood.likely, 5);
      final b = oracle(4).ask(Likelihood.likely, 5);
      expect((a.roll, a.yes, a.event), (b.roll, b.yes, b.event));
      expect(a.yes, a.roll <= a.chance);
    });

    test('many answers cover yes, no and exceptional results', () {
      final o = oracle(1);
      final answers = [for (var i = 0; i < 400; i++) o.ask(Likelihood.even, 5)];
      expect(answers.any((a) => a.yes), isTrue);
      expect(answers.any((a) => !a.yes), isTrue);
      expect(answers.any((a) => a.exceptional), isTrue);
      expect(answers.any((a) => a.event), isTrue);
      expect(answers.every((a) => a.roll >= 1 && a.roll <= 100), isTrue);
    });

    test('tables produce text and scene checks stay valid', () {
      final o = oracle(2);
      expect(o.meaning(), 'Gather · Debt');
      expect(o.descriptors(), 'Fragile · Door');
      expect(o.randomEvent(), 'A newcomer arrives: Gather · Debt');
      expect(o.discovery(), 'A hidden passage');
      expect(o.complication(), 'Time is running out');
      expect(_tables.list('reaction'), contains(o.reaction()));
      final outcomes = {for (var i = 0; i < 200; i++) o.sceneCheck(9)};
      expect(outcomes, containsAll(SceneOutcome.values));
      expect({
        for (var i = 0; i < 50; i++) o.sceneCheck(1),
      }, contains(SceneOutcome.expected));
    });
  });
}
