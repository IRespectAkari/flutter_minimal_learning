
import 'package:flutter/material.dart';

import 'package:flutter_minimal_learning/add_task_page.dart';
import 'package:flutter_minimal_learning/task.dart';
import 'package:flutter_minimal_learning/todo_list.dart';

class TodoPage extends StatefulWidget {
  final List<Task> tasks;
  final Future<void> Function(Task task) onTaskAdded;
  final Future<void> Function(Task task) onTaskUpdated;
  final Future<void> Function(Task task) onTaskDeleted;

  const TodoPage({
    super.key,
    required this.tasks,
    required this.onTaskAdded,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final taskList = widget.tasks.where((task) {
      return !task.hasTag('course');
    }).toList();

    final filteredTasks = taskList.where((task) {
      return task.title.contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: TodoList(
              tasks: filteredTasks,

              // 完了状態の変更
              onToggle: (index) async {
                final task = filteredTasks[index];

                task.update(
                  status: task.isCompleted
                      ? TaskStatus.todo
                      : TaskStatus.completed,
                );

                await widget.onTaskUpdated(task);
              },

              // 削除
              onDelete: (index) async {
                final task = filteredTasks[index];
                await widget.onTaskDeleted(task);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final title = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskPage(),
            ),
          );

          if (title == null || title.trim().isEmpty) {
            return;
          }

          final now = DateTime.now();

          final task = Task(
            id: 'task_${now.microsecondsSinceEpoch}',
            title: title.trim(),
            startTime: now,
            endTime: now,
          );

          await widget.onTaskAdded(task);
        },
      ),
    );
  }
}
