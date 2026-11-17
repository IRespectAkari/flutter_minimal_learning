// import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task.dart';

enum Tag {
  Category, Priority;

}
extension TagInfo on Tag {
  Color get color => switch(this) {
    Tag.Category => Colors.lightBlueAccent,
    Tag.Priority => Colors.lightGreen,
  };

  String get text => switch(this) {
    Tag.Category => "大学",
    Tag.Priority => "中",
  };
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.circular(12),
      ),

      child: _createCheckboxListTile(),
    );
  }

  Widget _createCheckboxListTile() {
    return CheckboxListTile(
      title: Column(
        children: [
          Row(children: [
              _createTag(Tag.Category),
              _createTag(Tag.Priority),
          ]),
          Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(children: [
            Icon(Icons.timelapse),
            Text("期限："),
            Text(_remainingText(task.endTime)),
          ])
        ],
      ),
      // title: Text(
      //   task.title,
      //   style: TextStyle(
      //       // decoration: task.done ? TextDecoration.lineThrough : null
      //       decoration: task.isCompleted ? TextDecoration.lineThrough : null
      //   ),
      // ),
      value: task.isCompleted,
      onChanged: (value) { onChanged(value ?? false); },
      // secondary: IconButton(
      //   icon: const Icon(Icons.delete),
      //   onPressed: onDelete,
      // ),

      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Container _createTag(Tag tag) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: tag.color),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.all(4),
      child: Text(tag.text),
    );
  }

  String _remainingText(DateTime endTime) {
    // print(endTime.isAfter(DateTime.now()));
    if(endTime.isBefore(DateTime.now())) return "期限切れ";

    return endTime.difference(DateTime.now()).toString();
  }

}
