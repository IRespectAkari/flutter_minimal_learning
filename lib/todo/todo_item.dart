import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task/task.dart';


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
      margin: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.circular(12),
      ),

      child: _createCheckboxListTile(),
    );
  }

  Widget _createCheckboxListTile() {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              spacing: 8,
              children: _createTags()
          ),

          Text(
            task.title,
            style: TextStyle(
              // decoration: task.done ? TextDecoration.lineThrough : null
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontSize: 20,
            ),
          ),

          Row(children: [
            Icon(Icons.access_time),
            Text("期限: "),
            Text(_limitText(task)),
          ],),
        ],),

      value: task.isCompleted,

      onChanged: (value) { onChanged(value ?? false); },
    );
  }

  List<Widget> _createTags() {
    return task.tags.map((txt) {
      return _createTag(txt);
    }).toList();
  }

  Widget _createTag(String txt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      
      padding: EdgeInsets.all(2),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.circular(4),
      ),

      child: Text(txt),
    );
  }

  String _limitText(Task task) {
    if(task.endTime.isBefore(DateTime.now())) {
      return "期限切れ";
    }

    Duration diff = task.endTime.difference(DateTime.now());
    int days = diff.inDays;
    int hours = diff.inHours.remainder(24);
    int minutes = diff.inMinutes.remainder(60);

    String day = days > 0 ? "$days日" : "";
    String hour = hours > 0 ? "$hours時間" : "";
    String minute = minutes > 0 ? "$minutes分" : "";

    return "あと$day$hour$minute";
  }
}
