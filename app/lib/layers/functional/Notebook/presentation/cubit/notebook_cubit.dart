import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/domain/use_cases/notebook_use_cases.dart';

typedef Clock = DateTime Function();

class NotebookCubit extends Cubit<Notebook> {
  NotebookCubit(
    ReadNotebookUseCase read,
    WatchNotebookUseCase watch,
    this._save,
    this._delete,
    this._export,
    this._import, {
    this.clock = DateTime.now,
  }) : super(read()) {
    _subscription = watch().listen(emit);
  }

  final SaveCampaignUseCase _save;
  final DeleteCampaignUseCase _delete;
  final ExportCampaignUseCase _export;
  final ImportCampaignUseCase _import;
  final Clock clock;
  late final StreamSubscription<Notebook> _subscription;

  Future<String> create(String title, CampaignKind kind) async {
    final campaign = NotebookCampaign.create(title.trim(), kind);
    await _save(campaign);
    return campaign.id;
  }

  Future<void> update(
    String id,
    NotebookCampaign Function(NotebookCampaign) change,
  ) async {
    final campaign = state.of(id);
    if (campaign != null) await _save(change(campaign));
  }

  Future<void> toggleFavorite(String id) =>
      update(id, (c) => c.copyWith(favorite: !c.favorite));

  Future<void> delete(String id) => _delete(id);

  Future<String> export(String id) => _export(id);

  Future<String> importFile(String source) => _import(source);

  Future<void> addLine(String id, JournalKind kind, String text) => update(
    id,
    (c) => c.withLine(JournalLine.create(kind, text.trim(), clock()), clock()),
  );

  Future<void> removeLine(String id, String sessionId, String lineId) => update(
    id,
    (c) => c.withSession(
      c.sessions.firstWhere((s) => s.id == sessionId).withoutLine(lineId),
    ),
  );

  Future<void> startSession(String id, String title) => update(
    id,
    (c) => c
        .copyWith(
          sessions: [
            for (final s in c.sessions) s.active ? s.ended(clock()) : s,
          ],
        )
        .withSession(JournalSession.start(title.trim(), clock())),
  );

  Future<void> endSession(String id) => update(
    id,
    (c) => c.copyWith(
      sessions: [for (final s in c.sessions) s.active ? s.ended(clock()) : s],
    ),
  );

  Future<String> addEntry(
    String id,
    EntryKind kind,
    String name, {
    String? parentId,
  }) async {
    final entry = NotebookEntry.create(kind, name.trim(), parentId: parentId);
    await update(id, (c) => c.withEntry(entry));
    return entry.id;
  }

  Future<void> saveEntry(String id, NotebookEntry entry) =>
      update(id, (c) => c.withEntry(entry));

  Future<void> removeEntry(String id, String entryId) =>
      update(id, (c) => c.withoutEntry(entryId));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
