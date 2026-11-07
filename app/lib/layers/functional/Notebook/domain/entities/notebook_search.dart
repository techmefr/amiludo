import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

class SearchHit {
  const SearchHit({this.entry, this.line, required this.snippet});
  final NotebookEntry? entry;
  final JournalLine? line;
  final String snippet;
}

String _snippet(String text, int at, int length) {
  final from = (at - 24).clamp(0, text.length);
  final to = (at + length + 40).clamp(0, text.length);
  return text.substring(from, to).replaceAll('\n', ' ');
}

List<SearchHit> searchCampaign(NotebookCampaign campaign, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return const [];
  final hits = <SearchHit>[];
  for (final entry in campaign.entries) {
    final nameAt = entry.name.toLowerCase().indexOf(needle);
    if (nameAt >= 0) {
      hits.add(SearchHit(entry: entry, snippet: entry.name));
      continue;
    }
    for (final text in entry.texts) {
      final at = text.toLowerCase().indexOf(needle);
      if (at < 0) continue;
      hits.add(
        SearchHit(entry: entry, snippet: _snippet(text, at, needle.length)),
      );
      break;
    }
  }
  for (final session in campaign.sessions.reversed) {
    for (final line in session.lines.reversed) {
      final at = line.text.toLowerCase().indexOf(needle);
      if (at < 0) continue;
      hits.add(
        SearchHit(line: line, snippet: _snippet(line.text, at, needle.length)),
      );
    }
  }
  return hits;
}
