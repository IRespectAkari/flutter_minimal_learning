import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({
    super.key,
    // this.initialIsAllDay = false,
    // this.initialTags = const [],
    required this.allTags,
    this.initialTask,
  });

  // final bool initialIsAllDay;
  // final List<String> initialTags;
  final Set<String> allTags;
  final Task? initialTask;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final controller = TextEditingController();
  late DateTime _startTime;
  late DateTime _endTime;
  late bool _isAllDay;
  late Set<String> _selectedTags;
  late Task _draftTask;
  late Set<String> _allTags;

  @override
  void initState() {
    super.initState();

    // 初期Taskを取得
    _draftTask = widget.initialTask?.copyWith() ?? Task.draft();

    // Taskからフォームの初期値を取得
    controller.text = _draftTask.title;
    _startTime = _draftTask.startTime;
    _endTime = _draftTask.endTime;
    _isAllDay = widget.initialTask?.isAllDay ?? false;
    // _selectedTags = widget.initialTask?.tags ?? [];
    final initialTask = widget.initialTask;
    if (initialTask != null) {
      _selectedTags = Set<String>.from(initialTask.tags);
    } else {
      _selectedTags = <String>{};
    }
    _allTags = widget.allTags;

    // final now = DateTime.now();
    // _startTime = DateTime(
    //   now.year,
    //   now.month,
    //   now.day,
    //   now.hour,
    //   now.minute,
    // );
    // _endTime = _startTime.add(const Duration(hours: 1));
    // _isAllDay = widget.initialIsAllDay;
    // _tags = widget.initialTags;
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return null;

    if (_isAllDay) return DateTime(date.year, date.month, date.day);

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

              // if (!_isAllDay) ...[
              ListTile(
                title: const Text('開始日時'),
                subtitle: Text(
                  '${_startTime.year}/${_startTime.month}/${_startTime.day}'
                  '${_isAllDay ? "" : ' ${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'}',
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
              if (!_isAllDay)
                ListTile(
                  title: const Text('終了日時'),
                  subtitle: Text(
                    '${_endTime.year}/${_endTime.month}/${_endTime.day} '
                    '${_isAllDay ? "" : ' ${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'}',
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
              // ],

              Text("タグ一覧"),
              _tags(),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  final task = _draftTask.copyWith(
                    title: controller.text,
                    startTime: _startTime,
                    endTime: _endTime,
                    isAllDay: _isAllDay,
                    tags: _selectedTags,
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

  Widget _tags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.allTags.map((tag) => _buildTag(tag, tag)).toList(),
    );
  }

  Widget _buildTag(String label, String? value) {
    var tag = (
      color: Color(0xFFF8E8E7),
      selectedColor: Color(0xFFFF91CA),
      label: label,
      value: value,
    );

    // valueが "" または null（「全て」ボタン）なら、選択リストが空のときにtrueにする
    // final bool selected = (tag.value == null || tag.value!.isEmpty)
    //     ? _selectedTags.isEmpty
    //     : _selectedTags.contains(tag.value);
    final bool selected = _selectedTags.contains(tag.value);

    return FilterChip(
      label: Text(tag.label),
      selected: selected,
      onSelected: (isSelected) {
        setState(() {
          if(isSelected) {
            _selectedTags.add(tag.label);
          }else {
            _selectedTags.remove(tag.label);
          }
        });
      },
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.fromLTRB(1, 4, 1, 4),
      showCheckmark: false, // チェックマークを消す
      backgroundColor: tag.color,
      selectedColor: tag.selectedColor,
    );
  }
}
