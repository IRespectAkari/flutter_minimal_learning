import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              decoration: const InputDecoration( labelText: 'タスク名' ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){ Navigator.pop(context, controller.text); },
              child: const Text('追加する'),
            )
          ],
        )
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Task task;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.done ? TextDecoration.lineThrough : null
        ),
      ),
      value: task.done,
      onChanged: (value) { onChanged(value ?? false); },
      secondary: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;

  const TodoList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index){
        return TodoItem(
          task: tasks[index],
          onChanged: (_) => onToggle(index),
          onDelete: () => onDelete(index),
        );
      }
    );
  }
}

class _TodoPageState extends State<TodoPage> {
  List<Task> tasks = [
    Task(title: 'Flutterを勉強する'),
    Task(title: 'Todoアプリを作る'),
    Task(title: '大学の課題をやる'),
  ];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task){
      return task.title.contains(searchQuery);
    }).toList();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar( title: const Text('My Todo') ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '検索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),

                onChanged: (value){
                  setState(() { searchQuery = value; });
                },
              )
            ),

            Expanded(
              child: TodoList(
                tasks: filteredTasks,
                onToggle: (index){
                  setState((){ filteredTasks[index].done = !filteredTasks[index].done; });
                },
                onDelete: (index){
                  setState(() { tasks.remove(filteredTasks[index]); });
                }
              )
            )
          ]
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final title = await Navigator.push<String>(
              context,
              MaterialPageRoute( builder: (context) => const AddTaskPage() ),
            );

            if(title != null && title.isNotEmpty){
              setState((){tasks.add(Task(title: title));});
            }
          },
        ),

      ),
    );
  }
}
