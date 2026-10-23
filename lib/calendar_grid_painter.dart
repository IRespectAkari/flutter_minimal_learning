
import 'package:flutter/material.dart';
import 'calendar_month_data.dart';

class CalendarGridPainter extends CustomPainter {
  CalendarGridPainter({
    required this.weekStart,
    required this.cellHeight,
    required this.lineColor,
    required this.monthBoundaryColor,
    required this.monthLabelColor,
  });

  final DateTime weekStart;
  final double cellHeight;
  final Color lineColor;
  final Color monthBoundaryColor;
  final Color monthLabelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / 7;

    final thinPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final thickPaint = Paint()
      ..color = monthBoundaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // 日付セルの背景色を月ごとに交互にする。
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final rect = Rect.fromLTWH(
        i * cellWidth,
        0,
        cellWidth,
        cellHeight,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..color = date.month.isEven
              ? const Color(0xFFFFD7D7)
              : const Color(0xFFE6E6FF),
              // 以下はダークモード用に残しておく
              // ? const Color(0xFF292B40)
              // : const Color(0xFF472D30),
      );
    }

    // 通常の縦線。
    for (int i = 0; i <= 7; i++) {
      final x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, cellHeight),
        thinPaint,
      );
    }

    // 月初・月末の境界を太くする。
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));

      if (CalendarMonthData.isMonthStart(date)) {
        final x = i * cellWidth;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, cellHeight),
          thickPaint,
        );
      }

      if (CalendarMonthData.isMonthEnd(date)) {
        final x = (i + 1) * cellWidth;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, cellHeight),
          thickPaint,
        );
      }
    }

    // 週の上下境界線。
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      thinPaint,
    );
    canvas.drawLine(
      Offset(0, cellHeight),
      Offset(size.width, cellHeight),
      thinPaint,
    );

    // その月の15日がこの週に含まれていれば月名を表示する。
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      if (date.day != 15) continue;

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${date.month}月',
          style: TextStyle(
            color: monthLabelColor,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // 15日のセル位置を基準に、週の中央付近へ配置。
      final x = (i + 0.5) * cellWidth - textPainter.width / 2;
      final y = (cellHeight - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CalendarGridPainter oldDelegate) {
    return oldDelegate.weekStart != weekStart ||
        oldDelegate.cellHeight != cellHeight ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.monthBoundaryColor != monthBoundaryColor ||
        oldDelegate.monthLabelColor != monthLabelColor;
  }
}
