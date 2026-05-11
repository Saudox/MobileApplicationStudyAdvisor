class Course {
  final String code;
  final String name;
  final String difficulty;
  final int level;
  final String category;
  final List<String> prerequisites;

  Course({
    required this.code,
    required this.name,
    required this.difficulty,
    required this.level,
    required this.category,
    this.prerequisites = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        code: json['code'] ?? '',
        name: json['name'] ?? json['display_name'] ?? '',
        difficulty: json['difficulty'] ?? 'easy',
        level: json['level'] ?? 0,
        category: json['category'] ?? 'general',
        prerequisites: List<String>.from(json['prerequisites'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'difficulty': difficulty,
        'level': level,
        'category': category,
        'prerequisites': prerequisites,
      };
}

class Stats {
  final int totalCourses;
  final int completedCourses;
  final double percentage;
  final Map<String, LevelStats> levels;

  Stats({
    required this.totalCourses,
    required this.completedCourses,
    required this.percentage,
    required this.levels,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    final levelsRaw = json['levels'] as Map<String, dynamic>? ?? {};
    final levels = levelsRaw.map((k, v) => MapEntry(k, LevelStats.fromJson(v)));
    return Stats(
      totalCourses: json['total_courses'] ?? 0,
      completedCourses: json['completed_courses'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      levels: levels,
    );
  }
}

class LevelStats {
  final int total;
  final int completed;

  LevelStats({required this.total, required this.completed});

  factory LevelStats.fromJson(Map<String, dynamic> json) => LevelStats(
        total: json['total'] ?? 0,
        completed: json['completed'] ?? 0,
      );
}
