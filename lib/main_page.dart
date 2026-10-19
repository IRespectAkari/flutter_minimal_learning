import 'package:flutter/material.dart';

import 'package:flutter_minimal_learning/task.dart';
import 'package:flutter_minimal_learning/task_data.dart';
import 'package:flutter_minimal_learning/task_database.dart';
import 'package:flutter_minimal_learning/todo_page.dart';
import 'package:flutter_minimal_learning/week_schedule_page.dart';
import 'package:flutter_minimal_learning/timetable_page.dart';
import 'package:flutter_minimal_learning/timetable2_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // SQLiteを初期化し、タスクを読み込む
  Future<void> _loadTasks() async {
    try {
      final database = TaskDatabase.instance;

      // 初回起動時だけ初期データを登録
      await database.initializeWithInitialTasks(initialTasks);

      // SQLiteから現在のタスク一覧を取得
      final loadedTasks = await database.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = loadedTasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // タスク追加
  Future<void> _addTask(Task task) async {
    await TaskDatabase.instance.insertTask(task);

    if (!mounted) return;
    setState(() {
      _tasks.add(task);
      _tasks.sort(
            (a, b) => a.startTime.compareTo(b.startTime),
      );
    });
  }

  // タスク更新
  Future<void> _updateTask(Task task) async {
    await TaskDatabase.instance.updateTask(task);

    if (!mounted) return;
    setState(() {
      // Taskは既存オブジェクトを更新しているため、
      // setStateによって各画面を再描画する。
    });
  }

  // タスク削除
  Future<void> _deleteTask(Task task) async {
    await TaskDatabase.instance.deleteTask(task.id);

    if (!mounted) return;
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('タスクの読み込みに失敗しました。\n$_error'),
        ),
      );
    }

    final pages = <Widget>[
      TodoPage(
        tasks: _tasks,
        onTaskAdded: _addTask,
        onTaskUpdated: _updateTask,
        onTaskDeleted: _deleteTask,
      ),
      WeekSchedulePage(tasks: _tasks),
      const TimetablePage(),
      Timetable2Page(tasks: _tasks),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      backgroundColor: Colors.blueGrey,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'todo_page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'week_schedule_page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_view),
            label: 'timetable_page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_5_sharp),
            label: 'timetable2_page',
          ),
        ],
        selectedItemColor: Colors.blue,
      ),
    );
  }
}
