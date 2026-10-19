
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/add_task_page.dart';
import 'package:flutter_minimal_learning/task.dart';
import 'package:flutter_minimal_learning/todo_list.dart';
import 'package:flutter_minimal_learning/task_data.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // List<Task> tasks = [
  //   Task(title: 'Flutterを勉強する', tags: [], startTime: new DateTime(2026)),
  //   Task(title: 'Todoアプリを作る', tags: [], startTime: new DateTime(2026)),
  //   Task(title: '大学の課題をやる', tags: [], startTime: new DateTime(2026)),
  // ];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tasklist = initialTasks.where((task){
      return !task.hasTag("course");
    }).toList();
    final filteredTasks = tasklist.where((task){
      return task.title.contains(searchQuery);
    }).toList();

    return MaterialApp(
      home: Scaffold(
        // backgroundColor: Colors.blueGrey,
        appBar: AppBar( title: const Text('Todo List') ),

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
                        // setState((){ filteredTasks[index].done = !filteredTasks[index].done; });
                        setState((){
                          filteredTasks[index].update(
                              status: filteredTasks[index].isCompleted
                                  ? TaskStatus.todo : TaskStatus.completed
                          );
                        });
                      },
                      onDelete: (index){
                        setState(() { initialTasks.remove(filteredTasks[index]); });
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
              setState((){initialTasks.add(Task(
                id: 'task_${Random().nextInt(100000)}',
                title: title,
                tags: [],
                startTime: DateTime(2026),
                endTime: DateTime(2026),
              ));});
            }
          },
        ),

      ),
    );
  }
}
