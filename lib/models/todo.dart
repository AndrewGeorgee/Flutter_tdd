import 'priority.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final Priority priority;
  final String category;
  final DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    Priority? priority,
    String? category,
    this.dueDate,
  }) : createdAt = createdAt ?? DateTime.now(),
       priority = priority ?? Priority.medium,
       category = category ?? '';

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inHours <= 24 && difference.inHours >= 0;
  }

  Todo toggleCompletion() {
    return copyWith(isCompleted: !isCompleted);
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    Priority? priority,
    String? category,
    DateTime? dueDate,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.value,
      'category': category,
      'dueDate': dueDate?.millisecondsSinceEpoch,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      priority: json['priority'] != null
          ? Priority.fromValue(json['priority'] as int)
          : null,
      category: json['category'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.priority == priority &&
        other.category == category &&
        other.dueDate?.millisecondsSinceEpoch ==
            dueDate?.millisecondsSinceEpoch;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      isCompleted,
      priority,
      category,
      dueDate?.millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
