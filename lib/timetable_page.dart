
import 'package:flutter/material.dart';

import 'package:flutter_minimal_learning/task.dart';
import 'package:flutter_minimal_learning/course_edit_dialog.dart';

class TimetablePage extends StatefulWidget {
  final List<Task> tasks;
  final Future<void> Function(Task task) onTaskAdded;
  final Future<void> Function(Task task) onTaskUpdated;
  final Future<void> Function(Task task) onTaskDeleted;

  const TimetablePage({
    super.key,
    required this.tasks,
    required this.onTaskAdded,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
  });

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  static const weekdays = ['月', '火', '水', '木', '金'];

  // 各時限の開始・終了時刻
  static const periodTimes = [
    [8, 50, 10, 20],
    [10, 30, 12, 0],
    [12, 50, 14, 20],
    [14, 30, 16, 0],
    [16, 10, 17, 40],
  ];

  // 指定した曜日・時限の講義を取得する
  List<Task> getCoursesAt(int period, int day) {
    return widget.tasks.where((task) {
      return task.hasTag('course') &&
          task.startTime.weekday == day + 1 &&
          task.details['period'] == (period + 1).toString();
    }).toList();
  }

  Future<void> editCell(int period, int day) async {
    final courses = getCoursesAt(period, day);

    // 現状は1セルにつき1講義を想定する
    final existingTask = courses.isEmpty ? null : courses.first;

    final controller = TextEditingController(
      text: existingTask?.title ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          child: Transform.translate(
            offset: Offset(
              0,
              -MediaQuery.sizeOf(context).height * 0.1,
            ),
            child: CourseEditDialog(
              title: existingTask?.title ?? '',
              weekday: weekdays[day],
              period: period,
            ),
          ),
        );
      },
    );

    controller.dispose();

    // キャンセルなら変更しない
    if (result == null) return;

    final title = result.trim();

    // 空欄なら既存の講義を削除
    if (title.isEmpty) {
      for (final task in courses) {
        await widget.onTaskDeleted(task);
      }
      return;
    }

    // 既存講義があれば名称を更新
    if (existingTask != null) {
      existingTask.title = title;
      existingTask.updatedAt = DateTime.now();

      await widget.onTaskUpdated(existingTask);
      return;
    }

    // 空のセルなら新しい講義を作成
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 今週の指定曜日の日付を求める
    final date = today.add(
      Duration(days: day + 1 - now.weekday),
    );

    final time = periodTimes[period];

    final task = Task(
      id: 'course_${now.microsecondsSinceEpoch}',
      title: title,
      startTime: DateTime(
        date.year,
        date.month,
        date.day,
        time[0],
        time[1],
      ),
      endTime: DateTime(
        date.year,
        date.month,
        date.day,
        time[2],
        time[3],
      ),
      tags: ['course'],
      details: {
        'weekday': (day + 1).toString(),
        'period': (period + 1).toString(),
      },
      recurrence: 'weekly',
    );

    await widget.onTaskAdded(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // 曜日ヘッダー
              _weeklyHeader(),

              // 5時限 × 5曜日
              _fiveByFive(),
              // Expanded(
              //   child: createFiveFive(),
              //   style: {
              //     alignment:
              //   }
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget applyLayout(Widget child, List<Widget Function(Widget)> wrappers) {
    for (final wrapper in wrappers.reversed) {
      child = wrapper(child);
    }
    return child;
  }

  Widget _fiveByFive(){
    return applyLayout(
      _createTimetable(),
      [
        (child) => Expanded(child: child),
        (child) => Align(alignment: Alignment.topCenter, child: child),
        (child) => FractionallySizedBox(heightFactor: 0.7, widthFactor: 1, child: child),
      ]
    );
  }

  Widget _createTimetable(){
    return Column(children: [
      for (int period = 0; period < 5; period++)
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 35,
                child: Center(
                  child: Text(
                    "${periodTimes[period][0]}:${periodTimes[period][1]}\n\n$period限\n\n${periodTimes[period][2]}:${periodTimes[period][3]}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),

              for (int day = 0; day < 5; day++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: InkWell(
                      onTap: () => editCell(period, day),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: getCoursesAt(period, day).isEmpty ? Colors.grey.shade100 : Colors.lightBlue.shade100,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getCoursesAt(period, day)
                              .map((task) => task.title)
                              .join('\n'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weeklyHeader(){
    final List<Widget> list = [
      for(final day in weekdays)
        Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ];

    return applyLayout(
      // list as Widget,
      Row(children: <Widget>[const SizedBox(width: 20), list]),
      [
        // (child) => Row(children: [const SizedBox(width: 20), child]),
        (child) => SizedBox(height: 20, child: child),
      ],
    );
  }

  SizedBox _weeklyHeader2() {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          const SizedBox(width: 28),
          for (final day in weekdays)
            Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
