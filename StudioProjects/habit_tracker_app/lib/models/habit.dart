class Habit {
  final String id;
  final String title;
  final String category;
  final int level;
  final int xp;
  final int health;
  final int completionsThisWeek;
  final int currentStreak;
  final List<DateTime> completionHistory;
  final DateTime createdAt;
  final DateTime? lastWitherAt;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    this.level = 1,
    this.xp = 0,
    this.health = 100,
    this.completionsThisWeek = 0,
    this.currentStreak = 0,
    this.completionHistory = const [],
    DateTime? createdAt,
    this.lastWitherAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DateTime? get lastCompletionAt =>
      completionHistory.isEmpty ? null : completionHistory.first;

  DateTime get baselineForWithering => lastCompletionAt ?? createdAt;

  bool get isWithering => health < 45;

  bool get isHealthy => health >= 70;

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
    List<DateTime>? completionHistory,
    DateTime? createdAt,
    Object? lastWitherAt = _unsetDate,
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
      completionHistory: completionHistory ?? this.completionHistory,
      createdAt: createdAt ?? this.createdAt,
      lastWitherAt: identical(lastWitherAt, _unsetDate)
          ? this.lastWitherAt
          : lastWitherAt as DateTime?,
    );
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    final historyRaw = map['completionHistory'] as List<dynamic>? ?? const [];
    final history = historyRaw
        .map((value) {
          return _parseDateStatic(value);
        })
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final createdAt =
        _parseDateStatic(map['createdAt']) ??
        (history.isNotEmpty ? history.last : DateTime.now());
    final lastWitherAt = _parseDateStatic(map['lastWitherAt']);

    return Habit(
      id: id,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      health: map['health'] as int? ?? 100,
      completionsThisWeek: map['completionsThisWeek'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      completionHistory: history,
      createdAt: createdAt,
      lastWitherAt: lastWitherAt,
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
      'completionHistory': completionHistory
          .map((entry) => entry.toIso8601String())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastWitherAt': lastWitherAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateStatic(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    final milliseconds = (value as dynamic).millisecondsSinceEpoch;
    if (milliseconds is int) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    return null;
  }
}

const _unsetDate = Object();
