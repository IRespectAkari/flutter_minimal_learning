import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/timetable_page.dart';
import 'package:flutter_minimal_learning/todo_page.dart';
import 'package:flutter_minimal_learning/week_schedule_page.dart';
import 'package:flutter_minimal_learning/timetable2_page.dart';
import 'package:flutter_minimal_learning/task_data.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex = 0;
  // List<Task> tasks = [
  //   Task(title: 'Flutterを勉強する', tags: [], startTime: new DateTime(2026)),
  //   Task(title: 'Todoアプリを作る', tags: [], startTime: new DateTime(2026)),
  //   Task(title: '大学の課題をやる', tags: [], startTime: new DateTime(2026)),
  //   Task(title: '情報ネットワーク入門', tags: ["course"], startTime: new DateTime(2026), weekday: 1),
  //   Task(title: '消費者行動論', tags: ["course"], startTime: new DateTime(2026)),
  //   Task(title: '社会学', tags: ["course"], startTime: new DateTime(2026)),
  //   Task(title: '宗教学', tags: ["course"], startTime: new DateTime(2026)),
  //   Task(title: 'Webデザイン', tags: ["course"], startTime: new DateTime(2026)),
  //   Task(title: 'アプリ共同開発', tags: ["course"], startTime: new DateTime(2026)),
  //
  // ];

  late final List<Widget> _pages = [
    const TodoPage(),
    const WeekSchedulePage(),
    const TimetablePage(),
    Timetable2Page(tasks: tasks),
    // CalendarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      backgroundColor: Colors.blueGrey,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
        // backgroundColor: Colors.white12,

        items: const <BottomNavigationBarItem>[
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
