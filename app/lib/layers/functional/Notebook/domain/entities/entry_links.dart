import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

class LinkSegment {
  const LinkSegment(this.text, [this.entryId]);
  final String text;
  final String? entryId;
}

List<LinkSegment> linkSegments(String text, List<NotebookEntry> entries) {
  final named = entries.where((e) => e.name.trim().isNotEmpty).toList()
    ..sort((a, b) => b.name.length.compareTo(a.name.length));
  if (named.isEmpty && !text.contains('[[')) return [LinkSegment(text)];
  final names = named.map((e) => RegExp.escape(e.name.trim())).join('|');
  final pattern = RegExp(
    r'\[\[([^\]]+)\]\]'
    '${names.isEmpty ? '' : '|(?<![\\p{L}\\p{N}])(?:$names)(?![\\p{L}\\p{N}])'}',
    caseSensitive: false,
    unicode: true,
  );
  String? find(String name) => named
      .where((e) => e.name.trim().toLowerCase() == name.trim().toLowerCase())
      .firstOrNull
      ?.id;
  final result = <LinkSegment>[];
  var last = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > last) {
      result.add(LinkSegment(text.substring(last, match.start)));
    }
    final label = match.group(1) ?? match.group(0)!;
    result.add(LinkSegment(label, find(label)));
    last = match.end;
  }
  if (last < text.length) result.add(LinkSegment(text.substring(last)));
  return result;
}

Set<String> linkedIds(String text, List<NotebookEntry> entries) => {
  for (final s in linkSegments(text, entries))
    if (s.entryId != null) s.entryId!,
};

class Backlinks {
  const Backlinks({this.entries = const [], this.lines = const []});
  final List<NotebookEntry> entries;
  final List<String> lines;
}

Backlinks backlinks(NotebookCampaign campaign, String entryId) {
  final target = campaign.entry(entryId);
  if (target == null) return const Backlinks();
  bool mentions(String text) =>
      linkedIds(text, campaign.entries).contains(entryId);
  return Backlinks(
    entries: [
      for (final e in campaign.entries)
        if (e.id != entryId && e.texts.any(mentions)) e,
    ],
    lines: [
      for (final s in campaign.sessions)
        for (final l in s.lines)
          if (mentions(l.text)) l.text,
    ],
  );
}
