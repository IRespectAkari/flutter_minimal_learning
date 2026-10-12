// class Task {
//   String title;
//   bool done;
//   DateTime startTime;
//   DateTime endTime;
//   List<String> tags;
//   int weekday;
//
//   Task({
//     required this.title,
//     this.done = false,
//     required this.startTime,
//     this.endTime = .new(2099),
//     required this.tags,
//     this.weekday = 0,
//   });
// }
enum TaskStatus {
  todo,
  inProgress,
  completed,
  cancelled,
}

class Task {
  final String id;
  String title;
  String description;

  DateTime startTime;
  DateTime endTime;

  bool isAllDay;
  List<String> tags;
  Map<String, String> details;

  TaskStatus status;

  final DateTime createdAt;
  DateTime updatedAt;

  DateTime? reminderTime;

  // 例: 'weekly'、'daily'
  String? recurrence;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    List<String> tags = const [],
    Map<String, String> details = const {},
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.reminderTime,
    this.recurrence,
  })  : tags = List<String>.from(tags),
        details = Map<String, String>.from(details),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    if (endTime.isBefore(startTime)) {
      throw ArgumentError('終了日時は開始日時より前にできません');
    }
  }

  bool get isCompleted => status == TaskStatus.completed;

  bool hasTag(String tag) => tags.contains(tag);

  void update({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    List<String>? tags,
    Map<String, String>? details,
    TaskStatus? status,
    DateTime? reminderTime,
    String? recurrence,
  }) {
    final newStart = startTime ?? this.startTime;
    final newEnd = endTime ?? this.endTime;

    if (newEnd.isBefore(newStart)) {
      throw ArgumentError('終了日時は開始日時より前にできません');
    }

    if (title != null) this.title = title;
    if (description != null) this.description = description;
    this.startTime = newStart;
    this.endTime = newEnd;

    if (isAllDay != null) this.isAllDay = isAllDay;
    if (tags != null) this.tags = List<String>.from(tags);
    if (details != null) {
      this.details = Map<String, String>.from(details);
    }
    if (status != null) this.status = status;
    if (reminderTime != null) this.reminderTime = reminderTime;
    if (recurrence != null) this.recurrence = recurrence;

    updatedAt = DateTime.now();
  }
}