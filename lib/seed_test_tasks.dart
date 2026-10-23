
import 'package:flutter_minimal_learning/task.dart';
import 'package:flutter_minimal_learning/task_database.dart';

// 開発用：テストタスクを一括登録する
Future<void> seedTestTasks() async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var idCounter = 0;

  Future<void> add({
    required String title,
    required int day,
    int hour = 9,
    int minute = 0,
    int duration = 60,
    String description = '',
    List<String> tags = const [],
    TaskStatus status = TaskStatus.todo,
    bool allDay = false,
    String? recurrence,
    bool reminder = false,
  }) async {
    final start = allDay
        ? today.add(Duration(days: day))
        : today.add(Duration(
      days: day,
      hours: hour,
      minutes: minute,
    ));

    final end = allDay
        ? start.add(const Duration(hours: 23, minutes: 59))
        : start.add(Duration(minutes: duration));

    final created = now.subtract(
      Duration(days: (day.abs() % 14) + 1),
    );

    final task = Task(
      id: 'test_${now.microsecondsSinceEpoch}_${idCounter++}',
      title: title,
      description: description,
      startTime: start,
      endTime: end,
      isAllDay: allDay,
      tags: tags,
      status: status,
      createdAt: created,
      updatedAt: created,
      reminderTime: reminder
          ? start.subtract(const Duration(minutes: 30))
          : null,
      recurrence: recurrence,
    );

    await TaskDatabase.instance.insertTask(task);
  }

  // ── 過去：完了した予定・未完了の予定 ──

  await add(
    title: 'データベース論 課題提出',
    day: -12,
    hour: 20,
    duration: 45,
    tags: ['university', 'assignment'],
    status: TaskStatus.completed,
  );
  await add(
    title: '参考書を購入',
    day: -10,
    hour: 17,
    duration: 30,
    tags: ['shopping'],
    status: TaskStatus.completed,
  );
  await add(
    title: 'アルバイト',
    day: -9,
    hour: 17,
    duration: 240,
    tags: ['part-time'],
    status: TaskStatus.completed,
  );
  await add(
    title: 'ネットワーク演習の復習',
    day: -8,
    hour: 19,
    duration: 90,
    tags: ['study', 'network'],
    status: TaskStatus.todo,
  );
  await add(
    title: '部屋の掃除',
    day: -7,
    hour: 10,
    duration: 60,
    tags: ['housework'],
    status: TaskStatus.completed,
  );
  await add(
    title: '友人と食事',
    day: -6,
    hour: 18,
    duration: 120,
    tags: ['private'],
    status: TaskStatus.completed,
  );
  await add(
    title: 'プログラミング課題',
    day: -5,
    hour: 21,
    duration: 120,
    tags: ['university', 'assignment'],
    status: TaskStatus.inProgress,
  );
  await add(
    title: '洗濯',
    day: -4,
    hour: 8,
    duration: 60,
    tags: ['housework'],
    status: TaskStatus.completed,
  );
  await add(
    title: '古い予定のキャンセル',
    day: -3,
    hour: 14,
    duration: 60,
    tags: ['private'],
    status: TaskStatus.cancelled,
  );
  await add(
    title: '基本情報技術の復習',
    day: -2,
    hour: 20,
    duration: 90,
    tags: ['study', 'IT'],
    status: TaskStatus.completed,
  );

  // ── 今日：時間帯をばらけさせる ──

  await add(
    title: 'メールを確認',
    day: 0,
    hour: 8,
    minute: 15,
    duration: 15,
    tags: ['personal'],
  );
  await add(
    title: '情報ネットワーク入門',
    day: 0,
    hour: 10,
    minute: 30,
    duration: 90,
    tags: ['course'],
  );
  await add(
    title: '昼食',
    day: 0,
    hour: 12,
    duration: 45,
    tags: ['private'],
    status: TaskStatus.completed,
  );
  await add(
    title: '課題の進捗確認',
    day: 0,
    hour: 14,
    minute: 30,
    duration: 45,
    tags: ['university', 'assignment'],
    status: TaskStatus.inProgress,
    reminder: true,
  );
  await add(
    title: '食料品の買い出し',
    day: 0,
    hour: 17,
    duration: 45,
    tags: ['shopping'],
  );
  await add(
    title: 'FlutterのDB処理を確認',
    day: 0,
    hour: 20,
    duration: 90,
    tags: ['development', 'Flutter'],
    status: TaskStatus.inProgress,
  );

  // ── 未来：大学・開発・生活・趣味 ──

  await add(
    title: '消費者行動論',
    day: 1,
    hour: 12,
    minute: 50,
    duration: 90,
    tags: ['course'],
    recurrence: 'weekly',
  );
  await add(
    title: 'レポートの構成を考える',
    day: 1,
    hour: 16,
    duration: 60,
    tags: ['university', 'assignment'],
    reminder: true,
  );
  await add(
    title: 'アルバイト',
    day: 2,
    hour: 17,
    duration: 240,
    tags: ['part-time'],
  );
  await add(
    title: 'Flutterの画面レイアウト改善',
    day: 2,
    hour: 20,
    duration: 120,
    tags: ['development', 'Flutter'],
  );
  await add(
    title: '社会学',
    day: 3,
    hour: 10,
    minute: 30,
    duration: 90,
    tags: ['course'],
    recurrence: 'weekly',
  );
  await add(
    title: '図書館で資料を探す',
    day: 3,
    hour: 14,
    duration: 60,
    tags: ['university', 'study'],
  );
  await add(
    title: '部屋の片付け',
    day: 4,
    hour: 9,
    duration: 90,
    tags: ['housework'],
  );
  await add(
    title: '友人と遊ぶ',
    day: 4,
    hour: 13,
    duration: 180,
    tags: ['private'],
  );
  await add(
    title: 'ネットワークの問題演習',
    day: 5,
    hour: 10,
    duration: 120,
    tags: ['study', 'network'],
    reminder: true,
  );
  await add(
    title: '日用品の買い出し',
    day: 5,
    hour: 15,
    duration: 45,
    tags: ['shopping'],
  );
  await add(
    title: '個人開発の進捗整理',
    day: 6,
    hour: 19,
    duration: 60,
    tags: ['development'],
  );
  await add(
    title: '来週の予定を整理',
    day: 7,
    hour: 20,
    duration: 30,
    tags: ['personal'],
  );

  // ── 終日予定・締め切り ──

  await add(
    title: 'レポート提出期限',
    day: 8,
    allDay: true,
    tags: ['university', 'deadline'],
    reminder: true,
  );
  await add(
    title: '学費の支払いを確認',
    day: 9,
    allDay: true,
    tags: ['administration', 'deadline'],
  );
  await add(
    title: '大学の休講日',
    day: 10,
    allDay: true,
    tags: ['university'],
  );
  await add(
    title: '資格試験の申し込み',
    day: 12,
    allDay: true,
    tags: ['study', 'deadline'],
  );
  await add(
    title: '歯科の予約',
    day: 14,
    hour: 11,
    minute: 30,
    duration: 30,
    tags: ['appointment'],
    reminder: true,
  );
  await add(
    title: 'プロジェクトの中間確認',
    day: 15,
    hour: 13,
    duration: 60,
    tags: ['development', 'meeting'],
  );
  await add(
    title: '友人の誕生日',
    day: 18,
    allDay: true,
    tags: ['private', 'event'],
  );
  await add(
    title: '定期券の更新',
    day: 21,
    allDay: true,
    tags: ['administration'],
  );
  await add(
    title: 'レポートの最終確認',
    day: 24,
    hour: 19,
    duration: 120,
    tags: ['university', 'assignment'],
    reminder: true,
  );
  await add(
    title: '部屋の大掃除',
    day: 28,
    hour: 10,
    duration: 180,
    tags: ['housework'],
  );
  await add(
    title: '来月の予定を計画',
    day: 30,
    hour: 20,
    duration: 45,
    tags: ['personal'],
  );

  print('テストタスクの登録完了');
}
