import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

enum CampaignKind { solo, gm }

class NotebookCampaign {
  const NotebookCampaign({
    required this.id,
    required this.title,
    this.kind = CampaignKind.solo,
    this.favorite = false,
    this.palette,
    this.headerImageId,
    this.chaos = 5,
    this.sessions = const [],
    this.entries = const [],
    this.pinLinks = const {},
  });

  factory NotebookCampaign.create(String title, CampaignKind kind) =>
      NotebookCampaign(id: notebookId(), title: title, kind: kind);

  factory NotebookCampaign.fromJson(Map<String, dynamic> j) => NotebookCampaign(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    kind: CampaignKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => CampaignKind.solo,
    ),
    favorite: j['favorite'] == true,
    palette: (j['palette'] as num?)?.toInt(),
    headerImageId: j['headerImageId'] as String?,
    chaos: ((j['chaos'] as num?)?.toInt() ?? 5).clamp(1, 9),
    sessions: [
      for (final s in j['sessions'] as List? ?? const [])
        JournalSession.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
    entries: [
      for (final e in j['entries'] as List? ?? const [])
        NotebookEntry.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    pinLinks: Map<String, String>.from(j['pinLinks'] as Map? ?? const {}),
  );

  final String id, title;
  final CampaignKind kind;
  final bool favorite;
  final int? palette;
  final String? headerImageId;
  final int chaos;
  final List<JournalSession> sessions;
  final List<NotebookEntry> entries;
  final Map<String, String> pinLinks;

  JournalSession? get activeSession =>
      sessions.where((s) => s.active).lastOrNull;

  Set<String> get imageIds => {
    ?headerImageId,
    for (final e in entries) ...e.pictureIds,
  };

  NotebookEntry? entry(String entryId) =>
      entries.where((e) => e.id == entryId).firstOrNull;

  NotebookCampaign copyWith({
    String? title,
    CampaignKind? kind,
    bool? favorite,
    int? chaos,
    List<JournalSession>? sessions,
    List<NotebookEntry>? entries,
    Map<String, String>? pinLinks,
  }) => NotebookCampaign(
    id: id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    favorite: favorite ?? this.favorite,
    palette: palette,
    headerImageId: headerImageId,
    chaos: chaos ?? this.chaos,
    sessions: sessions ?? this.sessions,
    entries: entries ?? this.entries,
    pinLinks: pinLinks ?? this.pinLinks,
  );

  NotebookCampaign withLook({int? palette, String? headerImageId}) =>
      NotebookCampaign(
        id: id,
        title: title,
        kind: kind,
        favorite: favorite,
        palette: palette,
        headerImageId: headerImageId,
        chaos: chaos,
        sessions: sessions,
        entries: entries,
        pinLinks: pinLinks,
      );

  NotebookCampaign withEntry(NotebookEntry next) {
    final known = entries.any((e) => e.id == next.id);
    return copyWith(
      entries: known
          ? [for (final e in entries) e.id == next.id ? next : e]
          : [...entries, next],
    );
  }

  NotebookCampaign withoutEntry(String entryId) => copyWith(
    entries: [
      for (final e in entries)
        if (e.id != entryId) e.parentId == entryId ? e.withoutParent() : e,
    ],
    pinLinks: {
      for (final p in pinLinks.entries)
        if (p.value != entryId && !p.key.startsWith('$entryId/'))
          p.key: p.value,
    },
  );

  NotebookCampaign withSession(JournalSession next) {
    final known = sessions.any((s) => s.id == next.id);
    return copyWith(
      sessions: known
          ? [for (final s in sessions) s.id == next.id ? next : s]
          : [...sessions, next],
    );
  }

  NotebookCampaign withLine(JournalLine line, DateTime at) {
    final session = activeSession ?? JournalSession.start('', at);
    return withSession(session.withLine(line));
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'kind': kind.name,
    'favorite': favorite,
    'palette': palette,
    'headerImageId': headerImageId,
    'chaos': chaos,
    'sessions': [for (final s in sessions) s.toJson()],
    'entries': [for (final e in entries) e.toJson()],
    'pinLinks': pinLinks,
  };
}
