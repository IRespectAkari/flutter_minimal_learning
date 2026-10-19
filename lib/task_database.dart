import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'task.dart';

class TaskDatabase {
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

  // 初期データを一度だけ登録する
  Future<void> initializeWithInitialTasks(
      List<Task> initialTasks,
      ) async {
    final db = await database;

    await db.transaction((txn) async {
      final result = await txn.query(
        'app_meta',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['initial_tasks_seeded'],
        limit: 1,
      );

      // 登録済みなら何もしない
      if (result.isNotEmpty) return;

      // 初期データをまとめて登録
      for (final task in initialTasks) {
        await txn.insert('tasks', task.toMap());
      }

      // 登録済みの印を付ける
      await txn.insert('app_meta', {
        'key': 'initial_tasks_seeded',
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
}
