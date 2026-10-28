class TaskPreview {
  final int id;
  final String title;
  final String priority;
  final String dueDate;

  TaskPreview({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
  });

  factory TaskPreview.fromJson(Map<String, dynamic> json) {
    return TaskPreview(
      id: int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Low',
      dueDate: json['due_date']?.toString() ?? '',
    );
  }
}

class ExamPreview {
  final int id;
  final String title;
  final String subjectName;
  final String examDate;

  ExamPreview({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.examDate,
  });

  factory ExamPreview.fromJson(Map<String, dynamic> json) {
    return ExamPreview(
      id: int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      examDate: json['exam_date']?.toString() ?? '',
    );
  }
}

class DashboardSummary {
  final int subjectsCount;
  final int pendingTasksCount;
  final int upcomingExamsCount;
  final double completionRate;
  final List<TaskPreview> todayPriorities;
  final List<ExamPreview> upcomingExams;

  DashboardSummary({
    required this.subjectsCount,
    required this.pendingTasksCount,
    required this.upcomingExamsCount,
    required this.completionRate,
    required this.todayPriorities,
    required this.upcomingExams,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      subjectsCount: int.parse((json['subjects_count'] ?? 0).toString()),
      pendingTasksCount:
          int.parse((json['pending_tasks_count'] ?? 0).toString()),
      upcomingExamsCount:
          int.parse((json['upcoming_exams_count'] ?? 0).toString()),
      completionRate:
          double.parse((json['completion_rate'] ?? 0).toString()),
      todayPriorities: (json['today_priorities'] as List<dynamic>? ?? [])
          .map((e) => TaskPreview.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingExams: (json['upcoming_exams'] as List<dynamic>? ?? [])
          .map((e) => ExamPreview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DashboardSummary.empty() {
    return DashboardSummary(
      subjectsCount: 0,
      pendingTasksCount: 0,
      upcomingExamsCount: 0,
      completionRate: 0,
      todayPriorities: [],
      upcomingExams: [],
    );
  }
}
