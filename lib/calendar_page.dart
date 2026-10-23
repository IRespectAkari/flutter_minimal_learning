
import 'package:flutter/material.dart';

import 'calendar_grid_painter.dart';
import 'calendar_month_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

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
                    padding: const EdgeInsets.only(top: 3, right: 4),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '${weekStart.add(Duration(days: i)).day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: i == 0 ? Colors.redAccent
                               : i == 6 ? Color(0xFF313AFF)
                               : Colors.black,
                          // 以下はダークモード用に残しておく
                          // color: i == 0
                          //     ? Colors.redAccent : i == 6
                          //     ? Colors.lightBlueAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
