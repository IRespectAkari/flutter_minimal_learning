import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/radialAction/radial_action.dart';
import 'package:flutter_minimal_learning/radialAction/radial_action_button.dart';

import 'package:flutter_minimal_learning/task/task.dart';
import 'package:flutter_minimal_learning/task/task_data.dart';
import 'package:flutter_minimal_learning/task/task_database.dart';
import 'package:flutter_minimal_learning/todo/add_task_page.dart';

import 'package:flutter_minimal_learning/todo/todo_page.dart';

import 'package:flutter_minimal_learning/weekSchedule/week_schedule_page.dart';
import 'package:flutter_minimal_learning/timetable/timetable_page.dart';
import 'package:flutter_minimal_learning/calendar/calendar_page.dart';
import 'package:flutter_minimal_learning/option/option_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

enum AppPage {
  calendar("カレンダー", Icons.calendar_month),
  weekSchedule("週間スケジュール", Icons.calendar_view_week),
  timetable("時間割", Icons.grid_view),
  todo("タスク", Icons.checklist);
  // settings("設定", Icons.settings);

  final String title;
  final IconData icon;

  const AppPage(this.title, this.icon);
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isAnimatingByTap = false;
  AppPage _selectedPage = AppPage.calendar;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // BottomNavigationBarタップ時の処理
  Future<void> _onBottomNavTapped(int index) async {
    setState(() {
      _currentIndex = index;
      _isAnimatingByTap = true;
      _selectedPage = AppPage.values[index];
    });

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutSine,
    );

    _isAnimatingByTap = false;
  }


  final Set<String> _defaultTags = const {
    'event',
    'private',
    'shopping',
    'study',
    'part-time',
    'work',
  };
  final List<String> _defaultDropdownlist = const ["1年後期", "2年前期", "2年後期"];


  List<Task> _tasks = [];
  Set<String> _tags = {};
  bool _isLoading = true;
  List<RadialAction> _radialActionsList = [];
  String? _error;

  List<String> _dropdownList = [];
  // late String _selectedTerm = _dropdownList[0];
  late String _selectedTerm = "";

  @override
  void initState() {
    super.initState();
    _loadByDatabase();
  }

  // SQLiteを初期化し、タスクを読み込む
  Future<void> _loadByDatabase() async {
    try {
      final database = TaskDatabase.instance;

      // 初回起動時だけ初期データを登録
      await database.initializeWithInitialTasks(initialTasks);

      // SQLiteから現在のタスク一覧を取得
      final loadedTasks = await database.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = loadedTasks;
        _tags = _defaultTags;
        _dropdownList = _defaultDropdownlist;
        _selectedTerm = _dropdownList[0];
        _isLoading = false;
        _radialActionsList = [
          // 左：終日タスク
          RadialAction(
            label: "終日",
            icon: Icons.today,
            // offset: const Offset(-96, 0),
            offset: const Offset(-146, 0),
            onSelected: _createAddTaskHandler(
              draftTask: Task.draft(isAllDay: true),
            ),
          ),

          // 左上：課題タグ付きタスク
          RadialAction(
            label: '課題',
            icon: Icons.assignment_outlined,
            // offset: const Offset(-68, -68),
            offset: const Offset(-103, -103),
            onSelected: _createAddTaskHandler(
              draftTask: Task.draft(tags: {'study'}),
            ),
          ),

          // 上：緊急タグ付きタスク
          RadialAction(
            label: '仕事',
            // icon: Icons.priority_high,
            icon: Icons.work,
            // offset: const Offset(0, -96),
            offset: const Offset(0, -146),
            onSelected: _createAddTaskHandler(
              draftTask: Task.draft(tags: {'work'}),
            ),
          ),
        ];
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
      _tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  // タスク更新
  Future<void> _updateTask(Task updatedTask) async {
    await TaskDatabase.instance.updateTask(updatedTask);

    if (!mounted) return;
    setState(() {
      // Taskは既存オブジェクトを更新しているため、
      // setStateによって各画面を再描画する。
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1){
        _tasks[index] = updatedTask;
        _tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
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

  Widget _buildPageHeader(AppPage selectedPage) {
    return switch (selectedPage) {
      AppPage.weekSchedule => Text(selectedPage.title),

      AppPage.todo => Row(children: [
        Text(selectedPage.title),
        // todo: hasTag("course")を1か所にまとめる
        Text("（${_tasks.where((task) => !task.hasTag('course')).length}）"),
      ],),

      AppPage.timetable => DropdownButton<String>(
          value: _selectedTerm,
          items: createDropdownItems(_dropdownList),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedTerm = value);
          },
        ),

      _ => Text(selectedPage.title)
    };
  }

  Widget buildPage(AppPage page) {
    return switch (page) {
      AppPage.todo => TodoPage(
          tasks: _tasks,
          tags: _tags,
          // mainPageController: _pageController,
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

      // AppPage.settings => Timetable2Page(tasks: _tasks),
      AppPage.calendar => CalendarPage(tasks: _tasks),
    };
  }

  Future<void> Function(BuildContext) _createAddTaskHandler({Task? draftTask}) {
    return (context) async {
      final task = await Navigator.push<Task>(
        context,
        MaterialPageRoute(
          builder: (_) => AddTaskPage(
            allTags: _tags,
            initialTask: draftTask,
          ),
        ),
      );

      if (task == null || task.title.trim().isEmpty) {
        return;
      }

      await _addTask(task);
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
        // leading: IconButton(onPressed: ()=>{}, icon: const Icon(Icons.menu)),
        title: _buildPageHeader(_selectedPage),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OptionPage())
              );
            }
          )
        ],
        centerTitle: _selectedPage == AppPage.timetable,
      ),
      drawer: Drawer(
        elevation: 16,
        child: Container(
          color: Colors.blue,
          child: ListView(
            children: <Widget>[
              DrawerHeader(child: Text("MENU")),
              ListTile(title: Text("カレンダー"), onTap: ()=>Navigator.pop(context),),
              ListTile(title: Text("スケジュール"), onTap: ()=>Navigator.pop(context),),
              ListTile(title: Text("時間割"), onTap: ()=>Navigator.pop(context),),
              ListTile(title: Text("タスク一覧"), onTap: ()=>Navigator.pop(context),),
              UserAccountsDrawerHeader(accountName: Text("大空あかり"), accountEmail: Text("z2251503@std.kiis.ac.jp"))
            ],
          ),
        ),
      ),

      endDrawer: Drawer(
        elevation: 16,
        child: Container(
          color: Colors.redAccent,
          child: ListView(
            children: <Widget>[
              DrawerHeader(child: Text("へっだぁ")),
              ListTile(title: Text("めにゅーで開いた時"), onTap: ()=>Navigator.pop(context),),
              ListTile(title: Text("ぼたんで開いた時"), onTap: ()=>Navigator.pop(context),),
              UserAccountsDrawerHeader(accountName: Text("大空あかり"), accountEmail: Text("z2251503@std.kiis.ac.jp"))
            ],
          ),
        ),
      ),

      // 画面端からスワイプでドロワーが開く幅（論理ピクセル）
      // 35～50程度がスマホでの0.5～1cmに相当
      // drawerEdgeDragWidth: 40.0,

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (!_isAnimatingByTap) {
            setState(() {
              _currentIndex = index;
              _selectedPage = AppPage.values[index];

            });
          }
        },
        children: AppPage.values.map((page) => buildPage(page)).toList(),
      ),

      // 下部のナビゲーションバー
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: AppPage.values.map((page) =>
          BottomNavigationBarItem(icon: Icon(page.icon), label: page.title)
        ).toList(),
      ),


      // body: buildPage(_selectedPage),
      // resizeToAvoidBottomInset: false,

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedPage.index,
      //   onTap: (index) => setState((){ _selectedPage = AppPage.values[index]; }),
      //   items: AppPage.values.map((page) {
      //     return BottomNavigationBarItem(
      //       icon: Icon(page.icon),
      //       label: page.title,
      //     );
      //   }).toList(),
      //
      //   selectedItemColor: Colors.blue,
      // ),

      backgroundColor: Colors.blueGrey,

      floatingActionButton: (_selectedPage == AppPage.weekSchedule) ?
        null : RadialActionButton(
                 onTap: _createAddTaskHandler(),
                 actions: _radialActionsList,
               ),
    );
  }
}
