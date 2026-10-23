import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final controller = TextEditingController();
  late DateTime _startTime;
  late DateTime _endTime;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _startTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    _endTime = _startTime.add(const Duration(hours: 1));
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null || !mounted) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

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
              SwitchListTile(
                title: const Text('終日'),
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value;
                  });
                },
              ),

              if (!_isAllDay) ...[
                ListTile(
                  title: const Text('開始日時'),
                  subtitle: Text(
                    '${_startTime.year}/'
                        '${_startTime.month}/'
                        '${_startTime.day} '
                        '${_startTime.hour.toString().padLeft(2, '0')}:'
                        '${_startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final result = await _pickDateTime(_startTime);

                    if (result != null && mounted) {
                      setState(() {
                        _startTime = result;

                        // 終了時刻が開始時刻以前になった場合は1時間後にする
                        if (!_endTime.isAfter(_startTime)) {
                          _endTime = _startTime.add(
                            const Duration(hours: 1),
                          );
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('終了日時'),
                  subtitle: Text(
                    '${_endTime.year}/'
                        '${_endTime.month}/'
                        '${_endTime.day} '
                        '${_endTime.hour.toString().padLeft(2, '0')}:'
                        '${_endTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final result = await _pickDateTime(_endTime);

                    if (result != null && mounted) {
                      setState(() {
                        _endTime = result;
                      });
                    }
                  },
                ),
              ],
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  final task = Task(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: controller.text,
                    startTime: _startTime,
                    endTime: _endTime,
                    isAllDay: _isAllDay,
                  );

                  Navigator.pop<Task>(context, task);
                },
                child: const Text('追加する'),
              )
            ],
          )
      ),
    );
  }
}
