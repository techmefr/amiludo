import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../technical/Storage/store_database.dart';
import '../../technical/Appearance/appearance.dart';
import '../Game/domain/game.dart';
import '../Templates/domain/game_template.dart';
import '../Timer/domain/game_clock.dart';
import 'domain/workspace.dart';

final databaseProvider = Provider<StoreDatabase>((ref) {
  final db = StoreDatabase();
  ref.onDispose(db.close);
  return db;
});
final workspaceProvider = AsyncNotifierProvider<WorkspaceController, Workspace>(
  WorkspaceController.new,
);
final saveErrorProvider = NotifierProvider<SaveError, String?>(SaveError.new);

class SaveError extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

class WorkspaceController extends AsyncNotifier<Workspace> {
  Future<void> _writes = Future.value();
  final time = MonotonicTime();
  @override
  Future<Workspace> build() async {
    final raw = await ref.read(databaseProvider).readDocument('workspace');
    return raw == null
        ? const Workspace()
        : Workspace.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Workspace get data => state.requireValue;
  Map<String, ClockSnapshot> get savedClocks => {
    ...data.sessionClocks,
    if (data.currentId != null)
      data.currentId!: ClockSnapshot(
        data.clock.pause(time.now),
        data.bankMode,
        data.reverse,
      ),
  };
  Future<void> saveWorkspace(Workspace value) {
    state = AsyncData(value);
    final payload = value.export();
    _writes = _writes
        .then(
          (_) => ref.read(databaseProvider).writeDocument('workspace', payload),
        )
        .then(
          (_) => ref.read(saveErrorProvider.notifier).set(null),
          onError: (Object error, StackTrace stack) {
            ref
                .read(saveErrorProvider.notifier)
                .set(
                  'Enregistrement impossible. Exportez vos données avant de fermer.',
                );
          },
        );
    return _writes;
  }

  Future<void> retrySave() => saveWorkspace(data);
  Future<void> appearance(Appearance value) =>
      saveWorkspace(data.copyWith(appearance: value));
  Future<void> saveProfile(String name) => saveWorkspace(
    data.copyWith(
      profiles: [...data.profiles, StyleProfile(name, data.appearance)],
    ),
  );
  Future<void> removeProfile(int index) => saveWorkspace(
    data.copyWith(profiles: [...data.profiles]..removeAt(index)),
  );
  Future<void> game(GameSession value) => saveWorkspace(
    data.copyWith(games: [value, ...data.games.where((g) => g.id != value.id)]),
  );
  Future<void> startGame(
    String title,
    List<String> names,
    GameTemplate template,
  ) {
    if (names.isEmpty ||
        names.length > 32 ||
        names.map((n) => n.trim()).toSet().length != names.length ||
        names.any((n) => n.trim().isEmpty || n.length > 40)) {
      throw const FormatException('Choisissez 1 à 32 prénoms différents.');
    }
    const colors = [
      0xffe9ad8d,
      0xffbdb2e3,
      0xffc1da84,
      0xffe1c476,
      0xff8ac6d4,
      0xffe7a0c5,
    ];
    final id = newId();
    final players = [
      for (var i = 0; i < names.length; i++)
        Player(
          id: '$id-$i',
          name: names[i].trim(),
          color: colors[i % colors.length],
        ),
    ];
    final current = GameSession(
      id: id,
      title: title.trim().isEmpty ? template.name : title.trim(),
      pack: template,
      players: players,
      categories: template.categories,
      target: template.target,
      lowestWins: template.lowestWins,
      cooperative: template.cooperative,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    return saveWorkspace(
      data.copyWith(
        games: [current, ...data.games],
        currentId: id,
        sessionClocks: savedClocks,
        reverse: false,
        playerNames: names,
        clock: GameClock(
          remainingMs: template.seconds * 1000,
          durationMs: template.seconds * 1000,
        ),
        banks: {
          ...data.banks,
          for (final p in players) p.id: template.seconds * 1000,
        },
        bankMode: template.id == 'duel',
      ),
    );
  }

  Future<void> score(String player, double value, String category) =>
      game(data.current!.addScore(player, value, category));
  Future<void> undo() => game(data.current!.undo());
  Future<void> redo() => game(data.current!.redo());
  Future<void> nextRound() =>
      game(data.current!.copyWith(round: data.current!.round + 1));
  Future<void> clock(GameClock clock) =>
      saveWorkspace(data.copyWith(clock: clock));
  Future<void> toggleClock() => clock(
    data.clock.isRunning
        ? data.clock.pause(time.now)
        : data.clock.start(time.now),
  );
  Future<void> configureClock(int seconds, int increment, bool bank) =>
      saveWorkspace(
        data.copyWith(
          clock: GameClock(
            remainingMs: seconds * 1000,
            durationMs: seconds * 1000,
            incrementMs: increment * 1000,
          ),
          bankMode: bank,
          banks: {
            for (final p in data.current?.players ?? <Player>[])
              p.id: seconds * 1000,
          },
        ),
      );
  Future<void> nextTurn() {
    final current = data.current!;
    final next = current.nextTurn(reverse: data.reverse);
    final banks = {...data.banks};
    final remaining = data.clock.remainingAt(time.now) + data.clock.incrementMs;
    banks[current.players[current.activeIndex].id] = remaining;
    final budget = data.bankMode
        ? (banks[next.players[next.activeIndex].id] ?? data.clock.durationMs)
        : data.clock.durationMs;
    final nextClock = GameClock(
      remainingMs: budget,
      durationMs: data.clock.durationMs,
      incrementMs: data.clock.incrementMs,
    );
    return saveWorkspace(
      data.copyWith(
        games: [next, ...data.games.where((g) => g.id != next.id)],
        banks: banks,
        clock: data.clock.isRunning ? nextClock.start(time.now) : nextClock,
      ),
    );
  }

  Future<void> finish() async {
    final current = data.current!;
    await game(
      current.copyWith(finishedAt: DateTime.now().millisecondsSinceEpoch),
    );
    await clock(data.clock.pause(time.now));
  }

  Future<void> deleteGame(String id) {
    final clocks = {...savedClocks}..remove(id);
    return saveWorkspace(
      Workspace(
        appearance: data.appearance,
        profiles: data.profiles,
        games: data.games.where((g) => g.id != id).toList(),
        templates: data.templates,
        characters: data.characters,
        playerNames: data.playerNames,
        favorites: data.favorites,
        currentId: data.currentId == id ? null : data.currentId,
        clock: data.currentId == id ? const GameClock() : data.clock,
        banks: data.banks,
        sessionClocks: clocks,
        bankMode: data.bankMode,
        reverse: data.reverse,
      ),
    );
  }

  Future<void> chooseGame(String id) {
    if (!data.games.any((g) => g.id == id)) {
      throw ArgumentError('Partie inconnue');
    }
    final snapshots = savedClocks;
    final saved = snapshots[id];
    return saveWorkspace(
      data.copyWith(
        currentId: id,
        sessionClocks: snapshots,
        clock: saved?.clock ?? const GameClock(),
        bankMode: saved?.bankMode ?? false,
        reverse: saved?.reverse ?? false,
      ),
    );
  }

  Future<void> addTemplate(GameTemplate template) => saveWorkspace(
    data.copyWith(
      templates: [
        template,
        ...data.templates.where((t) => t.id != template.id),
      ],
    ),
  );
  Future<void> toggleFavorite(String tool) => saveWorkspace(
    data.copyWith(
      favorites: data.favorites.contains(tool)
          ? data.favorites.where((t) => t != tool).toList()
          : [...data.favorites, tool],
    ),
  );
  Future<void> importBackup(String text) async {
    if (text.length > 20000000) {
      throw const FormatException('Fichier trop volumineux');
    }
    final imported = Workspace.fromJson(
      Map<String, dynamic>.from(jsonDecode(text) as Map),
    );
    await saveWorkspace(
      imported.copyWith(
        clock: imported.clock.pause(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
