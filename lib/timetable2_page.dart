
import 'package:flutter/material.dart';
import 'task.dart';

class Timetable2Page extends StatefulWidget {
  // 親から共有されているTask一覧を受け取る
  final List<Task> tasks;

  const Timetable2Page({
    super.key,
    required this.tasks,
  });

  @override
  State<Timetable2Page> createState() => _Timetable2PageState();
}

class _Timetable2PageState extends State<Timetable2Page> {
  static const weekdays = ['月', '火', '水', '木', '金'];

  static const periods = [
    '8:50\n1限',
    '10:30\n2限',
    '12:50\n3限',
    '14:30\n4限',
    '16:10\n5限',
  ];

  // 各時限の開始時刻（分単位）
  static const periodStartMinutes = [
    8 * 60 + 50,
    10 * 60 + 30,
    12 * 60 + 50,
    14 * 60 + 30,
    16 * 60 + 10,
  ];

  // // courseタグのTaskだけを抽出
  // List<Task> get courses {
  //   return widget.tasks
  //       .where((task) => task.tags.contains('course'))
  //       .toList();
  // }

  // 講義だけを抽出
  List<Task> get courses => widget.tasks
      .where((task) => task.hasTag('course'))
      .toList();

  // Taskの開始時刻から時限を求める
  int? getPeriod(Task task) {
    final minutes =
        task.startTime.hour * 60 + task.startTime.minute;

    for (int i = 0; i < periodStartMinutes.length; i++) {
      if (minutes == periodStartMinutes[i]) {
        return i;
      }
    }

    return null;
  }

  // // 指定された曜日・時限のTaskを取得
  // List<Task> getTasksAt(int weekday, int period) {
  //   return courses.where((task) {
  //     return task.details["weekday"] == weekday &&
  //         getPeriod(task) == period;
  //   }).toList();
  // }

  // 曜日と時限で検索
  List<Task> getTasksAt(int weekday, int period) {
    return courses.where((task) {
      return task.startTime.weekday == weekday &&
          task.details['period'] == period.toString();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // 曜日ヘッダー
              SizedBox(
                height: 36,
                child: Row(
                  children: [
                    const SizedBox(width: 48),
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
              ),

              // 5行 × 5列
              Expanded(
                child: Column(
                  children: [
                    for (int period = 0; period < 5; period++)
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Center(
                                child: Text(
                                  periods[period],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),

                            for (int day = 0; day < 5; day++)
                              Expanded(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(2),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    padding:
                                    const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        for (final task
                                        in getTasksAt(
                                            day + 1, period + 1))
                                          // ↑ここで＋1しないと、1つ下にズレる！
                                          Flexible(
                                            child: Text(
                                              task.title,
                                              textAlign:
                                              TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}