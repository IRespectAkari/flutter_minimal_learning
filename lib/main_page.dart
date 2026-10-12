import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/todo_page.dart';


import 'package:flutter_minimal_learning/week_schedule_page.dart';class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TodoPage(),
    WeekSchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: const Text('My Todo') ),

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
            label: 'タブ1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'タブ2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_5_sharp),
            label: 'タブ3',
          ),
        ],
        selectedItemColor: Colors.blue,
      ),
    );
  }
}