import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_minimal_learning/task/task.dart';

class TaskDatabase {
  static const String _initialTasksSeededKey = 'initial_tasks_seeded';
  static const String _databaseResetKey = 'database_reset';

  // データベースを管理するインスタンス
  static final TaskDatabase instance = TaskDatabase._();

  TaskDatabase._();

  Database? _database;

  // データベースを取得する。未作成なら初期化する。
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // データベースファイルを開く
  Future<Database> _initDatabase() async {
    final dbPath = join(
      await getDatabasesPath(),
      'tasks.db',
    );

    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            isAllDay INTEGER NOT NULL,
            tags TEXT NOT NULL,
            details TEXT NOT NULL,
            status TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            reminderTime TEXT,
            recurrence TEXT
          )
        ''');

        await _createMetaTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createMetaTable(db);
        }
      },
    );
  }

  // 初期データ登録済みかどうかを記録するテーブル
  Future<void> _createMetaTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // 初回起動時のみ初期データを登録する
  Future<void> initializeWithInitialTasks(
      List<Task> initialTasks,
      ) async {
    final db = await database;

    await db.transaction((txn) async {
      final seeded = await txn.query(
        'app_meta',
        where: 'key = ?',
        whereArgs: [_initialTasksSeededKey],
      );

      final reset = await txn.query(
        'app_meta',
        where: 'key = ?',
        whereArgs: [_databaseResetKey],
      );

      // 登録済み、またはDBリセット後なら自動登録しない
      if (seeded.isNotEmpty || reset.isNotEmpty) return;

      for (final task in initialTasks) {
        await txn.insert('tasks', task.toMap());
      }

      await txn.insert('app_meta', {
        'key': _initialTasksSeededKey,
        'value': 'true',
      });
    });
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  // すべてのタスクを取得する
  Future<List<Task>> getTasks() async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      orderBy: 'startTime ASC',
    );

    return rows.map((row) => Task.fromMap(row)).toList();
  }

  // 指定IDのタスクを更新
  Future<void> updateTask(Task task) async {
    final db = await database;

    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // 指定IDのタスクを削除
  Future<void> deleteTask(String id) async {
    final db = await database;

    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 手動で初期データを読み込む
  // 読み込み済みなら false、読み込んだら true
  Future<bool> loadInitialTasks(List<Task> initialTasks) async {
    final db = await database;

    return db.transaction((txn) async {
      final seeded = await txn.query(
        'app_meta',
        where: 'key = ?',
        whereArgs: [_initialTasksSeededKey],
      );

      if (seeded.isNotEmpty) return false;

      for (final task in initialTasks) {
        await txn.insert('tasks', task.toMap());
      }

      await txn.insert('app_meta', {
        'key': _initialTasksSeededKey,
        'value': 'true',
      });

      // リセット状態を解除
      await txn.delete(
        'app_meta',
        where: 'key = ?',
        whereArgs: [_databaseResetKey],
      );

      return true;
    });
  }

  // データベースのデータをリセットする
  Future<void> resetDatabase() async {
    final db = await database;

    await db.transaction((txn) async {
      // 現在存在するタスクを全削除
      await txn.delete('tasks');

      // メタ情報を初期化
      await txn.delete('app_meta');

      // 起動時の自動初期データ登録を抑制する
      await txn.insert('app_meta', {
        'key': _databaseResetKey,
        'value': 'true',
      });
    });
  }
}
