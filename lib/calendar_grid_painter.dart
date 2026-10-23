
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

    // 月の領域の境界を描画する。
    bool isDifferentMonth(DateTime a, DateTime b) {
      return a.year != b.year || a.month != b.month;
    }

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));

      final left = i * cellWidth;
      final right = (i + 1) * cellWidth;

      // 月の領域における各セルの上下左右の境界。
      final previousDay = date.subtract(const Duration(days: 1));
      final nextDay = date.add(const Duration(days: 1));
      final previousWeek = date.subtract(const Duration(days: 7));
      final nextWeek = date.add(const Duration(days: 7));

      // 左側：日曜日（i == 0）には線を引かない
      if (i > 0 && isDifferentMonth(date, previousDay)) {
        canvas.drawLine(
          Offset(left, 0),
          Offset(left, cellHeight),
          thickPaint,
        );
      }

      // 右側：土曜日（i == 6）には線を引かない
      if (i < 6 && isDifferentMonth(date, nextDay)) {
        canvas.drawLine(
          Offset(right, 0),
          Offset(right, cellHeight),
          thickPaint,
        );
      }

      if (isDifferentMonth(date, previousWeek)) {
        canvas.drawLine(
          Offset(left, 0),
          Offset(right, 0),
          thickPaint,
        );
      }

      if (isDifferentMonth(date, nextWeek)) {
        canvas.drawLine(
          Offset(left, cellHeight),
          Offset(right, cellHeight),
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

      // 月グリッド全体の中央付近へ配置。
      final x = (size.width - textPainter.width) / 2;
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
