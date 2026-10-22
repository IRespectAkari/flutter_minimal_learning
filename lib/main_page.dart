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

enum AppPage {
  todo,
  weekSchedule,
  timetable,
  settings,
}
extension AppPageInfo on AppPage {
  String get title => switch (this) {
    AppPage.timetable => '時間割',
    AppPage.weekSchedule => '週間スケジュール',
    AppPage.todo => 'タスク一覧',
    AppPage.settings => '設定'
  };

  IconData get icon => switch (this) {
    AppPage.timetable => Icons.grid_view,
    // AppPage.timetable => Icons.table_view,
    AppPage.weekSchedule => Icons.calendar_view_week,
    AppPage.todo => Icons.checklist,
    AppPage.settings => Icons.settings,
  };
}

class _MainPageState extends State<MainPage> {
  AppPage _selectedPage = AppPage.todo;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _dropdownList = const ["1年後期", "2年前期", "2年後期"];
  late String _selectedTerm = _dropdownList[0];

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

  // 時間割の上部ドロップダウンメニューの自動生成関数
  List<DropdownMenuItem<String>> createDropdownItems(List<String> values) {
    return values.map((value) => DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    )).toList();
  }

  Widget _buildPageHeader() {
    return switch (_selectedPage) {
      AppPage.todo || AppPage.weekSchedule => Text(_selectedPage.title),

      AppPage.timetable => DropdownButton<String>(
          value: _selectedTerm,
          items: createDropdownItems(_dropdownList),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedTerm = value);
          },
        ),

      _ => Text(_selectedPage.title)
    };
  }

  Widget buildPage(AppPage page) {
    return switch (page) {
      AppPage.todo => TodoPage(
          tasks: _tasks,
          onTaskAdded: _addTask,
          onTaskUpdated: _updateTask,
          onTaskDeleted: _deleteTask,
        ),

      AppPage.weekSchedule => WeekSchedulePage(tasks: _tasks),

      AppPage.timetable => TimetablePage(
          tasks: _tasks,
          onTaskAdded: _addTask,
          onTaskUpdated: _updateTask,
          onTaskDeleted: _deleteTask,
        ),

      AppPage.settings => Timetable2Page(tasks: _tasks)
    };
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>{}, icon: const Icon(Icons.menu)),
        title: _buildPageHeader(),
        actions: [
          IconButton(onPressed: ()=>{}, icon: Icon(Icons.settings))
        ],
        centerTitle: _selectedPage == AppPage.timetable,
      ),

      body: buildPage(_selectedPage),

      backgroundColor: Colors.blueGrey,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage.index,
        onTap: (index) => setState((){ _selectedPage = AppPage.values[index]; }),
        items: AppPage.values.map((page) {
          return BottomNavigationBarItem(
            icon: Icon(page.icon),
            label: page.title,
          );
        }).toList(),

        selectedItemColor: Colors.blue,
      ),
    );
  }
}
