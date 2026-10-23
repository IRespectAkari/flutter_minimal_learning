
import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task.dart';

import 'calendar_grid_painter.dart';
import 'calendar_month_data.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;

  const CalendarPage({
    super.key,
    required this.tasks,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const double _cellHeight = 72;
  static const int _baseIndex = 100000;

  late final DateTime _baseSunday;
  late final ScrollController _scrollController;

  static const _weekdays = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();

    _baseSunday = CalendarMonthData.sundayOf(DateTime.now());

    _scrollController = ScrollController(
      initialScrollOffset: (_baseIndex - 4) * _cellHeight,
      // 今日が画面の中央に来るために、今日の上に「4」週分表示する
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: [
        for (final weekday in _weekdays)
          Expanded(
            child: SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  weekday,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWeek(int index) {
    final weekOffset = index - _baseIndex;
    final weekStart = CalendarMonthData.weekStartAt(
      _baseSunday,
      weekOffset,
    );

    return SizedBox(
      height: _cellHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: CalendarGridPainter(
              weekStart: weekStart,
              cellHeight: _cellHeight,
              lineColor: const Color(0xFF555568),
              monthBoundaryColor: const Color(0xFF7A7A7A),
              monthLabelColor: const Color(0xFF7A7A7A),
              // 下はダークモード用に残しておく
              // monthBoundaryColor: const Color(0xFFD6A52B),
              // monthLabelColor: const Color(0xFFD6A52B),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3, right: 3, left: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 日付は従来どおり右上に表示
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            '${weekStart.add(Duration(days: i)).day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: (i == 0 || i == 6) ? FontWeight.bold : FontWeight.w400,
                              color: i == 0 ? Colors.redAccent
                                   : i == 6 ? const Color(0xFF313AFF)
                                   : Colors.black,
                              // 以下はダークモード用に残しておく
                              // color: i == 0
                              //     ? Colors.redAccent : i == 6
                              //     ? Colors.lightBlueAccent : Colors.white,
                            ),
                          ),
                        ),

                        // その日の予定を表示
                        ..._getTasksForDate(weekStart.add(Duration(days: i)))
                          .map((task) => Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.3,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 開始日が一致するTask（講義を除く）を表示
  List<Task> _getTasksForDate(DateTime date) {
    return widget.tasks.where((task) {
      // まずは開始日が一致する予定だけを表示する。
      return task.startTime.year == date.year &&
          task.startTime.month == date.month &&
          task.startTime.day == date.day;
    })
    .where((task) => !task.hasTag('course'))
    .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            _buildWeekdayHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemExtent: _cellHeight,
                itemBuilder: (context, index) => _buildWeek(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
