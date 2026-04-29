import 'package:sqflite/sqflite.dart';

import 'schema.dart';

class LocalDatabase {
  LocalDatabase._(this.db);

  final Database db;

  static LocalDatabase? _instance;
  static LocalDatabase get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('LocalDatabase not initialized — call open() first');
    }
    return i;
  }

  static Future<LocalDatabase> open() async {
    if (_instance != null) return _instance!;
    final dbDir = await getDatabasesPath();
    final path = '$dbDir/exambank.db';
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        final batch = db.batch();
        for (final stmt in kSchemaV1) {
          batch.execute(stmt);
        }
        await batch.commit(noResult: true);
      },
    );
    _instance = LocalDatabase._(db);
    return _instance!;
  }

  /// Wipe user-scoped tables; preserve exam/question caches.
  Future<void> clearUserScopedTables() async {
    await db.transaction((txn) async {
      await txn.delete('users_cache');
      await txn.delete('attempts');
      await txn.delete('attempt_answers');
      await txn.delete('bookmarks');
      await txn.delete('pending_writes');
    });
  }

  Future<void> close() async {
    await db.close();
    _instance = null;
  }
}
