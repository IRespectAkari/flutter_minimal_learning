import 'package:flutter/material.dart';

void main() {
  runApp(const TodoPage());
}



class Task {
  String title;
  bool done;

  Task({
    required this.title,
    this.done = false,
  });
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Task> tasks = [
    Task(title: 'Flutterを勉強する'),
    Task(title: 'Todoアプリを作る'),
    Task(title: '大学の課題をやる'),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Todo'),
        ),

        body: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return CheckboxListTile(
              title: Text(task.title),
              value: task.done,
              onChanged: (value) {
                setState((){
                  task.done = value ?? false;
                });
              },
            );
          },
        )
      ),
    );
  }
}
