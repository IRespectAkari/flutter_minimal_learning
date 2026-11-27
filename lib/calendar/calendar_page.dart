
import 'package:flutter/material.dart';
import 'package:flutter_minimal_learning/task/task.dart';

import 'package:flutter_minimal_learning/calendar/calendar_grid_painter.dart';
import 'package:flutter_minimal_learning/calendar/calendar_month_data.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  const CalendarPage({
    super.key,
    required this.tasks,
    this.onDisplayedMonthChanged,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const double _cellHeight = 72;
  static const int _baseIndex = 100000;

  late final DateTime _baseSunday;
  late final ScrollController _scrollController;
  late DateTime _displayedMonth;// 表示中の年月を保持する変数

  // Stateに最後に通知した年月を保持
  DateTime? _lastReportedMonth;

  static const _weekdays = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();

    _baseSunday = CalendarMonthData.sundayOf(DateTime.now());

    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);

    _scrollController = ScrollController(
      initialScrollOffset: (_baseIndex - 4) * _cellHeight,
      // 今日が画面の中央に来るために、今日の上に「4」週分表示する
    );

    _scrollController.addListener(_updateDisplayedMonth);

    // 初回レイアウト完了後にも表示年月を更新する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateDisplayedMonth();
      }
    });
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

  // 年月を更新するメソッド
  void _updateDisplayedMonth() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // 画面中央のスクロール座標
    final centerOffset =
        position.pixels + position.viewportDimension / 2;

    // itemExtent が _cellHeight なので、スクロール位置をセルの高さで割れば、画面中央にある週のインデックスを求められます。
    // さらに、既存の _buildWeek() と同じ方法で週の開始日を取得できます。

    // 画面中央にある週のインデックス
    final weekIndex = (centerOffset / _cellHeight).floor();

    final weekOffset = weekIndex - _baseIndex;

    final weekStart = CalendarMonthData.weekStartAt(
      _baseSunday,
      weekOffset,
    );

    // 週の中央（水曜日）を基準に年月を判定
    final centerDate = weekStart.add(const Duration(days: 3));

    final newMonth = DateTime(
      centerDate.year,
      centerDate.month,
    );

    // 前回と同じ年月なら通知しない
    if (_lastReportedMonth?.year == newMonth.year &&
        _lastReportedMonth?.month == newMonth.month) {
      return;
    }

    _lastReportedMonth = newMonth;

    // MainPageに年月を通知
    widget.onDisplayedMonthChanged?.call(newMonth);
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '${_displayedMonth.year}年${_displayedMonth.month}月',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
