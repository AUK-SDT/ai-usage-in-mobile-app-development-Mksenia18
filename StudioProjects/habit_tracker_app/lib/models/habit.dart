class Habit {
  final String id;
  final String title;
  final String category;
  final int level;
  final int xp;
  final int health;
  final int completionsThisWeek;
  final int currentStreak;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    this.level = 1,
    this.xp = 0,
    this.health = 100,
    this.completionsThisWeek = 0,
    this.currentStreak = 0,
  });

  String get plantIcon {
    if (level == 1) return '🌱';
    if (level == 2) return '🌿';
    if (level == 3) return '🌸';
    return '🌳';
  }

  String get stageLabel {
    if (level == 1) return 'Seed';
    if (level == 2) return 'Sprout';
    if (level == 3) return 'Flower';
    return 'Tree';
  }

  Habit copyWith({
    String? id,
    String? title,
    String? category,
    int? level,
    int? xp,
    int? health,
    int? completionsThisWeek,
    int? currentStreak,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      health: health ?? this.health,
      completionsThisWeek: completionsThisWeek ?? this.completionsThisWeek,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      health: map['health'] as int? ?? 100,
      completionsThisWeek: map['completionsThisWeek'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'level': level,
      'xp': xp,
      'health': health,
      'completionsThisWeek': completionsThisWeek,
      'currentStreak': currentStreak,
    };
  }
}
