import 'dart:convert';

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

  // DB(SQLite)に保存するための変換メソッド
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay ? 1 : 0,
      'tags': jsonEncode(tags),
      'details': jsonEncode(details),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'recurrence': recurrence,
    };
  }

  // DB(SQLite)から取り出すための変換メソッド
  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      isAllDay: map['isAllDay'] == 1,
      tags: List<String>.from(
        jsonDecode(map['tags'] as String) as List,
      ),
      details: Map<String, String>.from(
        jsonDecode(map['details'] as String) as Map,
      ),
      status: TaskStatus.values.byName(
        map['status'] as String,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      reminderTime: map['reminderTime'] == null
          ? null
          : DateTime.parse(map['reminderTime'] as String),
      recurrence: map['recurrence'] as String?,
    );
  }
}