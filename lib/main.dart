import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: TodoPage()
    );
  }
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

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('タスクを追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'タスク名',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context, controller.text);
              },
              child: const Text('追加する'),
            )
          ],
        )
      ),
    );
  }
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTaskPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
