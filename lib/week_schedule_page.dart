// import 'package:flutter/material.dart';
//
// class WeekSchedulePage extends StatelessWidget {
//   const WeekSchedulePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('週間スケジュールのページ'),
//     );
//   }
// }

import 'package:flutter/material.dart';

const double _hourHeight = 44;
const double _timeRulerWidth = 48;

const int _startHour = 8;
const int _endHour = 18;

const int _startMinutes = _startHour * 60;
const int _endMinutes = _endHour * 60;
const int _hours = _endHour - _startHour;

const double _scheduleHeight = _hours * _hourHeight;
const double _pixelsPerMinute = _hourHeight / 60;

/// 週間スケジュール画面
class WeekSchedulePage extends StatelessWidget {
  const WeekSchedulePage({super.key});

  static const weekdays = ['月', '火', '水', '木', '金'];

  // 仮の予定データ。後からタスク等のデータに置き換える。
  static const events = <_ScheduleEvent>[
    _ScheduleEvent(
      dayIndex: 0,
      title: 'プログラミング',
      startMinutes: 9 * 60,
      endMinutes: 10 * 60 + 30,
      color: Color(0xFFC8E6C9),
    ),
    _ScheduleEvent(
      dayIndex: 0,
      title: '課題',
      startMinutes: 13 * 60,
      endMinutes: 14 * 60,
      color: Color(0xFFBBDEFB),
    ),
    _ScheduleEvent(
      dayIndex: 1,
      title: '宗教学',
      startMinutes: 10 * 60 + 30,
      endMinutes: 12 * 60,
      color: Color(0xFFD1C4E9),
    ),
    _ScheduleEvent(
      dayIndex: 2,
      title: '情報ネットワーク入門',
      startMinutes: 10 * 60 + 30,
      endMinutes: 12 * 60,
      color: Color(0xFFBBDEFB),
    ),
    _ScheduleEvent(
      dayIndex: 3,
      title: 'アルバイト',
      startMinutes: 14 * 60,
      endMinutes: 17 * 60,
      color: Color(0xFFFFE0B2),
    ),
    _ScheduleEvent(
      dayIndex: 4,
      title: 'レポート作成',
      startMinutes: 9 * 60,
      endMinutes: 11 * 60,
      color: Color(0xFFFFCDD2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 今週の月曜日を求める。
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day - today.weekday + 1,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 固定表示する曜日・日付ヘッダー
            Row(
              children: [
                const SizedBox(width: _timeRulerWidth),
                for (int i = 0; i < weekdays.length; i++)
                  Expanded(
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F5F7),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFD0D5DA),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdays[i],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10
                            ),
                          ),
                          Text(
                            '${monday.add(Duration(days: i)).day}日',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 時刻目盛りと月〜金を一緒にスクロールする。
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: _scheduleHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左側の時刻目盛り
                      const _TimeRuler(),

                      // 5曜日を1つの横並び領域にする。
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int dayIndex = 0; dayIndex < weekdays.length; dayIndex++)
                              Expanded(
                                child: _DayColumn(
                                  events: events
                                    .where((e) => e.dayIndex == dayIndex)
                                    .toList(),
                                ),
                              ),
                          ],
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
    );
  }
}

/// 左側の時刻目盛り
class _TimeRuler extends StatelessWidget {
  const _TimeRuler();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _timeRulerWidth,
      height: _scheduleHeight,
      child: Stack(
        children: [
          for (int hour = _startHour; hour <= _endHour; hour++)
            Positioned(
              top: (hour - _startHour) * _hourHeight - 9,
              left: 0,
              right: 4,
              child: Text(
                '$hour:00',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 曜日ごとの予定列
class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.events});

  final List<_ScheduleEvent> events;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _scheduleHeight,
      child: Stack(
        children: [
          // 背景の時間罫線
          const Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          // 時刻から位置・高さを計算してイベントを配置する。
          for (final event in events)
            if (event.endMinutes > _startMinutes &&
                event.startMinutes < _endMinutes)
              Positioned(
                top: (
                    (event.startMinutes < _startMinutes
                        ? _startMinutes
                        : event.startMinutes) -
                        _startMinutes
                ) *
                    _pixelsPerMinute,
                height: (
                    (event.endMinutes > _endMinutes
                        ? _endMinutes
                        : event.endMinutes) -
                        (event.startMinutes < _startMinutes
                            ? _startMinutes
                            : event.startMinutes)
                ) *
                    _pixelsPerMinute,
                left: 2,
                right: 2,
                child: _EventCard(event: event),
              ),
        ],
      ),
    );
  }
}

/// 時間軸の格子線
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D5DA)
      ..strokeWidth = 0.7;

    // 時間ごとの横線
    for (int i = 0; i <= _hours; i++) {
      final y = i * _hourHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 曜日の左右の境界線
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

/// 予定カード
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final _ScheduleEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: event.color,
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Text(
        event.title,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF30343B),
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
      ),
    );
  }
}

/// 予定データ
class _ScheduleEvent {
  const _ScheduleEvent({
    required this.dayIndex,
    required this.title,
    required this.startMinutes,
    required this.endMinutes,
    required this.color,
  });

  /// 月曜 = 0、火曜 = 1、...、金曜 = 4
  final int dayIndex;

  final String title;

  /// 午前0時からの経過分数
  final int startMinutes;
  final int endMinutes;

  final Color color;
}