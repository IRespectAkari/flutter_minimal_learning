
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TimetablePage(),
  ));
}

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final List<String> weekdays = ['月', '火', '水', '木', '金'];

  final List<String> periods = [
    '8:50\n1限',
    '10:30\n2限',
    '12:50\n3限',
    '14:30\n4限',
    '16:10\n5限',
  ];

  // timetable[時限][曜日]
  final List<List<String>> timetable = [
    ['', '', '', '', ''],
    ['', '', '情報ネットワーク入門', '', '宗教学'],
    ['消費者行動論', '', '', '', ''],
    ['社会学', '', '', '', ''],
    ['', '', '', 'Webデザイン', ''],
  ];

  Future<void> editCell(int period, int day) async {
    final controller = TextEditingController(
      text: timetable[period][day],
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${weekdays[day]}曜日 ${period + 1}限'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '講義名',
            hintText: '講義名を入力',
          ),
          onSubmitted: (value) =>
              Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        timetable[period][day] = result.trim();
      });
    }

    controller.dispose();
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

              // 5時限 × 5曜日
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
                                  padding: const EdgeInsets.all(2),
                                  child: InkWell(
                                    onTap: () =>
                                        editCell(period, day),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      padding:
                                      const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: timetable[period][day]
                                            .isEmpty
                                            ? Colors.grey.shade100
                                            : Colors.lightBlue.shade100,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        timetable[period][day].isEmpty
                                            ? ''
                                            : timetable[period][day],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
