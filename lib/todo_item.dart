import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task.dart';


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
            // decoration: task.done ? TextDecoration.lineThrough : null
            decoration: task.isCompleted ? TextDecoration.lineThrough : null
        ),
      ),
      value: task.isCompleted,
      onChanged: (value) { onChanged(value ?? false); },
      secondary: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
