import '../models/habit.dart';

class MockHabitService {
  Future<List<Habit>> fetchHabits() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Habit(
        id: '1',
        title: 'Drink Water',
        category: 'Health',
        level: 1,
        xp: 20,
        health: 95,
        completionsThisWeek: 3,
        currentStreak: 2,
      ),
      Habit(
        id: '2',
        title: 'Read Book',
        category: 'Study',
        level: 2,
        xp: 50,
        health: 90,
        completionsThisWeek: 2,
        currentStreak: 1,
      ),
      Habit(
        id: '3',
        title: 'Morning Workout',
        category: 'Fitness',
        level: 3,
        xp: 80,
        health: 88,
        completionsThisWeek: 4,
        currentStreak: 3,
      ),
    ];
  }
}
