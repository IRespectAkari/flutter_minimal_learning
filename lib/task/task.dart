import 'dart:convert';
import 'package:uuid/uuid.dart';

// 1. タスク自体の状態
enum TaskStatus {
  todo,
  inProgress,
  completed,
  cancelled,
}

// 2. 絞り込みタブ用のenum
enum TaskStatusFilter {
  todo('未完了'),
  completed('完了'),
  all('全て');

  // 表示用のラベル
  final String label;
  const TaskStatusFilter(this.label);

  // このフィルター条件に、タスクのステータスが合致するかを判定するメソッド
  bool matches(TaskStatus status) {
    switch (this) {
      case TaskStatusFilter.all:
        return true; // 全てなら無条件でOK
      case TaskStatusFilter.todo:
      // ※ inProgress（進行中）も「未完了」に含めるなら
        return status == TaskStatus.todo || status == TaskStatus.inProgress;
    // もし純粋な todo だけなら: return status == TaskStatus.todo;
      case TaskStatusFilter.completed:
        return status == TaskStatus.completed;
    }
  }
}

class Task {
  static final Uuid _uuid = Uuid();

  static String generateId() => _uuid.v4();

  final String id;
  final String title;
  final String description;

  final DateTime startTime;
  final DateTime endTime;

  final bool isAllDay;
  final Set<String> tags;
  final Map<String, String> details;

  final TaskStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime? reminderTime;

  // 例: 'weekly'、'daily'
  final String? recurrence;

  Task._({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    Set<String> tags = const {},
    Map<String, String> details = const {},
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.reminderTime,
    this.recurrence,
  })  : tags = Set<String>.unmodifiable(tags),
        details = Map<String, String>.unmodifiable(details),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    if (endTime.isBefore(startTime)) {
      throw ArgumentError('終了日時は開始日時より前にできません');
    }
  }

  factory Task.draft({
    // String id = "0000-draft-id",
    String title = "xxxx-draft-title",
    String description = '',
    DateTime? startTime,
    DateTime? endTime,
    bool isAllDay = false,
    Set<String> tags = const {},
    Map<String, String> details = const {},
    TaskStatus status = TaskStatus.todo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderTime,
    String? recurrence, // 元の型に合わせて調整してください
  }) {
    return Task._(
      id: generateId(),
      title: title,
      description: description,
      startTime: startTime ?? DateTime.now(),
      endTime: endTime ?? (startTime ?? DateTime.now()).add(const Duration(hours: 1)),
      isAllDay: isAllDay,
      tags: tags, // 通常コンストラクタ側で List.from されるので安全！
      details: details, // こちらも Map.from されるので安全！
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reminderTime: reminderTime,
      recurrence: recurrence,
    );
  }

  bool get isCompleted => status == TaskStatus.completed;

  bool hasTag(String tag) => tags.contains(tag);

  static const Object _unset = Object();

  Task copyWith({
    // String? id,// idを引き継ぐために、引数に書かない
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    Set<String>? tags,
    Map<String, String>? details,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? reminderTime = _unset,
    Object? recurrence = _unset,
  }) {
    return Task._(
      // id: id ?? this.id,
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      tags: tags ?? this.tags,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTime: identical(reminderTime, _unset)
          ? this.reminderTime
          : reminderTime as DateTime?,
      recurrence: identical(recurrence, _unset)
          ? this.recurrence
          : recurrence as String?,
    );
  }

  Task copyAsNew({
    // String? id,// idを新規作成する為に、引数に書かない
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    Set<String>? tags,
    Map<String, String>? details,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? reminderTime = _unset,
    Object? recurrence = _unset,
  }) {
    return Task._(
      // id: id ?? this.id,
      id: generateId(),
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      tags: tags ?? this.tags,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTime: identical(reminderTime, _unset)
          ? this.reminderTime
          : reminderTime as DateTime?,
      recurrence: identical(recurrence, _unset)
          ? this.recurrence
          : recurrence as String?,
    );
  }

  // void update({
  //   String? title,
  //   String? description,
  //   DateTime? startTime,
  //   DateTime? endTime,
  //   bool? isAllDay,
  //   List<String>? tags,
  //   Map<String, String>? details,
  //   TaskStatus? status,
  //   DateTime? reminderTime,
  //   String? recurrence,
  // }) {
  //   final newStart = startTime ?? this.startTime;
  //   final newEnd = endTime ?? this.endTime;
  //
  //   if (newEnd.isBefore(newStart)) {
  //     throw ArgumentError('終了日時は開始日時より前にできません');
  //   }
  //
  //   if (title != null) this.title = title;
  //   if (description != null) this.description = description;
  //   this.startTime = newStart;
  //   this.endTime = newEnd;
  //
  //   if (isAllDay != null) this.isAllDay = isAllDay;
  //   if (tags != null) this.tags = List<String>.from(tags);
  //   if (details != null) {
  //     this.details = Map<String, String>.from(details);
  //   }
  //   if (status != null) this.status = status;
  //   if (reminderTime != null) this.reminderTime = reminderTime;
  //   if (recurrence != null) this.recurrence = recurrence;
  //
  //   updatedAt = DateTime.now();
  // }

  // DB(SQLite)に保存するための変換メソッド
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay ? 1 : 0,
      'tags': jsonEncode(tags.toList()),
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
    return Task._(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      isAllDay: map['isAllDay'] == 1,
      tags: List<String>.from(
        jsonDecode(map['tags'] as String) as List,
      ).toSet(),
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