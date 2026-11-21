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
      padding: const EdgeInsets.all(0),

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
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      dense: true,
      minTileHeight: 0,
      minVerticalPadding: 3,


      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              spacing: 6,
              children: task.tags.map((txt) => _createTag(txt)).toList()
          ),

          Text(
            task.title,
            style: TextStyle(
              // decoration: task.done ? TextDecoration.lineThrough : null
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontSize: 13,
            ),
          ),

          Row(
            children: [
              Icon(Icons.access_time, size: 12),
              Text(" 期限: ", style: TextStyle(fontSize: 10)),
              Text(_limitText(task), style: TextStyle(fontSize: 10)),
            ],
          ),
        ],),

      value: task.isCompleted,

      onChanged: (value) { onChanged(value ?? false); },
    );
  }

  Widget _createTag(String txt) {
    return Container(
      padding: EdgeInsets.fromLTRB(3, 0, 3, 0),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.circular(4),
      ),

      child: Text(txt, style: TextStyle(fontSize: 11)),
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
