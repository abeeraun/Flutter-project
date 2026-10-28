enum ExamStatus { upcoming, completed }

ExamStatus examStatusFromString(String value) {
  return value == 'Completed' ? ExamStatus.completed : ExamStatus.upcoming;
}

String examStatusToString(ExamStatus status) {
  return status == ExamStatus.completed ? 'Completed' : 'Upcoming';
}

class Exam {
  final int id;
  final String title;
  final int subjectId;
  final String subjectName;
  final String examDate;
  final int totalMarks;
  final int? obtainedMarks;
  final ExamStatus status;
  final String createdAt;

  Exam({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.examDate,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.status,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      subjectId: int.parse((json['subject_id'] ?? 0).toString()),
      subjectName: json['subject_name']?.toString() ?? '',
      examDate: json['exam_date']?.toString() ?? '',
      totalMarks: int.parse((json['total_marks'] ?? 0).toString()),
      obtainedMarks: json['obtained_marks'] == null
          ? null
          : int.tryParse(json['obtained_marks'].toString()),
      status: examStatusFromString(json['status']?.toString() ?? 'Upcoming'),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject_id': subjectId,
      'exam_date': examDate,
      'total_marks': totalMarks,
      'obtained_marks': obtainedMarks,
      'status': examStatusToString(status),
    };
  }

  Exam copyWith({
    int? id,
    String? title,
    int? subjectId,
    String? subjectName,
    String? examDate,
    int? totalMarks,
    int? obtainedMarks,
    ExamStatus? status,
    String? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      examDate: examDate ?? this.examDate,
      totalMarks: totalMarks ?? this.totalMarks,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
