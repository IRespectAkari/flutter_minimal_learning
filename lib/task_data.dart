
import 'task.dart';

// 1限〜5限の開始・終了時刻
const periodTimes = [
  [8, 50, 10, 20],
  [10, 30, 12, 0],
  [12, 50, 14, 20],
  [14, 30, 16, 0],
  [16, 10, 17, 40],
];

// 基準となる月曜日
final baseMonday = DateTime(2026, 10, 12);

DateTime classDate(int weekday, int hour, int minute) {
  final date = baseMonday.add(Duration(days: weekday - 1));
  return DateTime(
    date.year,
    date.month,
    date.day,
    hour,
    minute,
  );
}

Task createCourseTask({
  required String id,
  required int weekday,
  required int period,
  required String title,
  required String room,
  required String teacher,
  required String memo,
}) {
  final time = periodTimes[period - 1];

  return Task(
    id: id,
    title: title,
    description: memo,
    startTime: classDate(weekday, time[0], time[1]),
    endTime: classDate(weekday, time[2], time[3]),
    tags: ['course'],
    details: {
      'room': room,
      'teacher': teacher,
      'weekday': weekday.toString(),
      'period': period.toString(),
    },
    recurrence: 'weekly',
  );
}

final List<Task> tasks = [
  createCourseTask(
    id: 'course-mon-3',
    weekday: 1,
    period: 3,
    title: '消費者行動論',
    room: '1号館 201室',
    teacher: '山田恒一',
    memo: '消費者心理と購買行動について学ぶ・資料配布あり',
  ),
  createCourseTask(
    id: 'course-mon-4',
    weekday: 1,
    period: 4,
    title: '社会学',
    room: '3号館 203室',
    teacher: '佐々木美香',
    memo: '社会構造と現代社会の課題を扱う・出席重視',
  ),
  createCourseTask(
    id: 'course-tue-2',
    weekday: 2,
    period: 2,
    title: '宗教学',
    room: '1号館 大講義室',
    teacher: '中川恒一',
    memo: '宗教の基礎概念と社会との関係を学ぶ・小レポートあり',
  ),
  createCourseTask(
    id: 'course-tue-3',
    weekday: 2,
    period: 3,
    title: '情報リテラシー演習２',
    room: '2号館 PC室1',
    teacher: '吉田拓也',
    memo: 'Officeソフトを使った実習中心・課題提出あり',
  ),
  createCourseTask(
    id: 'course-wed-1',
    weekday: 3,
    period: 1,
    title: 'キャリアデザイン2',
    room: '1号館 105室',
    teacher: '山口智子',
    memo: '就職活動やキャリア形成について考える・自己分析課題あり',
  ),
  createCourseTask(
    id: 'course-wed-2',
    weekday: 3,
    period: 2,
    title: '情報ネットワーク入門',
    room: '4号館 ネットワーク演習室',
    teacher: '森田和也',
    memo: 'ネットワークの基礎と通信の仕組みを学ぶ・実習あり',
  ),
  createCourseTask(
    id: 'course-wed-4',
    weekday: 3,
    period: 4,
    title: '情報数学１',
    room: '3号館 102室',
    teacher: '石井恒一',
    memo: '集合と論理・確率など情報系の基礎数学を扱う・小テストあり',
  ),
  createCourseTask(
    id: 'course-wed-5',
    weekday: 3,
    period: 5,
    title: 'インターンシップ実習',
    room: 'キャリア支援室',
    teacher: '藤田直子',
    memo: 'インターンシップに向けた事前指導・活動報告書の提出あり',
  ),
  createCourseTask(
    id: 'course-thu-2',
    weekday: 4,
    period: 2,
    title: 'プレゼミ2（競プロ）',
    room: '2号館 PC室2',
    teacher: '高田翔太',
    memo: 'プログラミングコンテスト形式の演習・C++推奨',
  ),
  createCourseTask(
    id: 'course-thu-5',
    weekday: 4,
    period: 5,
    title: 'Webデザイン',
    room: 'メディアセンター 実習室A',
    teacher: '小川里奈',
    memo: 'HTMLとCSSを使ったWeb制作・制作課題あり',
  ),
  createCourseTask(
    id: 'course-fri-1',
    weekday: 5,
    period: 1,
    title: 'プログラミング初歩Ⅱ',
    room: '2号館 PC室1',
    teacher: '岡本恒一',
    memo: 'プログラミングの基礎から応用演習まで扱う・課題提出あり',
  ),
  createCourseTask(
    id: 'course-fri-3',
    weekday: 5,
    period: 3,
    title: '情報倫理',
    room: '1号館 303室',
    teacher: '西村真紀',
    memo: '個人情報や著作権など情報社会の倫理を学ぶ・レポート課題あり',
  ),
];