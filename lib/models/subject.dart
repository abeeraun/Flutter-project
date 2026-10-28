class Subject {
  final int id;
  final String name;
  final String description;
  final String teacher;
  final String color;
  final String createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.teacher,
    required this.color,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      color: json['color']?.toString() ?? '#2196F3',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'teacher': teacher,
      'color': color,
    };
  }

  Subject copyWith({
    int? id,
    String? name,
    String? description,
    String? teacher,
    String? color,
    String? createdAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacher: teacher ?? this.teacher,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
