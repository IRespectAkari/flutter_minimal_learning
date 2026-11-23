import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task/task.dart';
import 'package:flutter_minimal_learning/todo/todo_item.dart';

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
    if(tasks.isEmpty){
      return const Center(child: Text('タスクがありません'));
    }

    return ListView.separated(
      itemCount: tasks.length,

      separatorBuilder: (context, index) => const SizedBox(height: 5),

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
