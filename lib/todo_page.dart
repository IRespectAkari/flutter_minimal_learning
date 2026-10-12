
import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/add_task_page.dart';
import 'package:flutter_minimal_learning/task.dart';
import 'package:flutter_minimal_learning/todo_list.dart';

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
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task){
      return task.title.contains(searchQuery);
    }).toList();

    return MaterialApp(
      home: Scaffold(
        // backgroundColor: Colors.blueGrey,

        body: Column(
            children: [
              // 検索欄
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

              // todolist表示ページ
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
