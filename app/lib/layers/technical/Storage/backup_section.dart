abstract class BackupSection {
  Future<void> load();
  Map<String, Object?> backup();
  Future<void> Function() restore(Map<String, dynamic> backup);
}
