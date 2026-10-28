enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

TaskPriority priorityFromString(String value) {
  switch (value) {
    case 'High':
      return TaskPriority.high;
    case 'Medium':
      return TaskPriority.medium;
    default:
      return TaskPriority.low;
  }
}

String priorityToString(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'High';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.low:
      return 'Low';
  }
}

TaskStatus statusFromString(String value) {
  switch (value) {
    case 'In Progress':
      return TaskStatus.inProgress;
    case 'Completed':
      return TaskStatus.completed;
    default:
      return TaskStatus.pending;
  }
}

String statusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.inProgress:
      return 'In Progress';
    case TaskStatus.completed:
      return 'Completed';
    case TaskStatus.pending:
      return 'Pending';
  }
}

class TaskItem {
  final int id;
  final String title;
  final String description;
  final int subjectId;
  final String subjectName;
  final String dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String createdAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subjectId: int.parse((json['subject_id'] ?? 0).toString()),
      subjectName: json['subject_name']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      priority: priorityFromString(json['priority']?.toString() ?? 'Low'),
      status: statusFromString(json['status']?.toString() ?? 'Pending'),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'due_date': dueDate,
      'priority': priorityToString(priority),
      'status': statusToString(status),
    };
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    int? subjectId,
    String? subjectName,
    String? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
