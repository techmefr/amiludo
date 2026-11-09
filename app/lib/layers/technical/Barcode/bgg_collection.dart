class BggCollectionItem {
  const BggCollectionItem({
    required this.name,
    this.imageUrl = '',
    this.minPlayers = 0,
    this.maxPlayers = 0,
    this.minutes = 0,
  });

  final String name, imageUrl;
  final int minPlayers, maxPlayers, minutes;
}

final _item = RegExp(r'<item\b[^>]*>(.*?)</item>', dotAll: true);
final _title = RegExp(r'<name[^>]*>([^<]*)</name>');
final _thumbnail = RegExp(r'<thumbnail>\s*([^<\s]*)\s*</thumbnail>');
final _stats = RegExp(r'<stats\b[^>]*>');

String _decode(String text) => text
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&');

int _attribute(String tag, String name) =>
    int.tryParse(RegExp('$name="(\\d+)"').firstMatch(tag)?.group(1) ?? '') ?? 0;

List<BggCollectionItem> parseBggCollection(String xml) => [
  for (final match in _item.allMatches(xml))
    if (_title.firstMatch(match.group(1)!)?.group(1) case final title?)
      BggCollectionItem(
        name: _decode(title).trim(),
        imageUrl: _decode(
          _thumbnail.firstMatch(match.group(1)!)?.group(1) ?? '',
        ),
        minPlayers: _attribute(
          _stats.firstMatch(match.group(1)!)?.group(0) ?? '',
          'minplayers',
        ),
        maxPlayers: _attribute(
          _stats.firstMatch(match.group(1)!)?.group(0) ?? '',
          'maxplayers',
        ),
        minutes: _attribute(
          _stats.firstMatch(match.group(1)!)?.group(0) ?? '',
          'playingtime',
        ),
      ),
];
