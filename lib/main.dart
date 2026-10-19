import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/main_page.dart';
import 'package:flutter_minimal_learning/task_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // SQLite の初期化
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // testDatabase();

  runApp(const MyApp());
}

Future<void> testDatabase() async {
  final database = TaskDatabase.instance;

  // final task = Task(
  //   id: 'sqlite_test_001',
  //   title: 'SQLiteの動作確認',
  //   startTime: DateTime(2026, 10, 20, 9, 0),
  //   endTime: DateTime(2026, 10, 20, 10, 0),
  // );

  print("-------------------");
// 保存
//   await database.insertTask(task);

// 更新
//   await database.updateTask(Task(
//     id: 'sqlite_test_001',
//     title: 'SQLiteのupdate動作確認',
//     startTime: DateTime(2026, 10, 20, 9, 0),
//     endTime: DateTime(2026, 10, 20, 10, 0),
//   ));

// 削除
  await database.deleteTask("sqlite_test_001");

// 読み込み
  final tasks = await database.getTasks();

  if(tasks.isEmpty) print("empty!");
  for (final task in tasks) {
    print('${task.id}: ${task.title}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: MainPage()
    );
  }
}

