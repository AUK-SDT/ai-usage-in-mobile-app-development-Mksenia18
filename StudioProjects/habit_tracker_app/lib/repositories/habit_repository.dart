import '../models/habit.dart';
import '../services/firebase_habit_service.dart';
import '../services/mock_habit_service.dart';

class HabitRepositoryResult {
  final List<Habit> habits;
  final bool firebaseConnected;
  final String? message;

  const HabitRepositoryResult({
    required this.habits,
    required this.firebaseConnected,
    this.message,
  });
}

class HabitRepository {
  final FirebaseHabitService firebaseService;
  final MockHabitService mockService;

  HabitRepository({
    FirebaseHabitService? firebaseService,
    MockHabitService? mockService,
  }) : firebaseService = firebaseService ?? FirebaseHabitService(),
       mockService = mockService ?? MockHabitService();

  Future<HabitRepositoryResult> fetchHabits() async {
    try {
      final habits = await firebaseService.fetchHabits();
      return HabitRepositoryResult(habits: habits, firebaseConnected: true);
    } catch (_) {
      final fallbackHabits = await mockService.fetchHabits();
      return HabitRepositoryResult(
        habits: fallbackHabits,
        firebaseConnected: false,
        message: 'Offline mock data',
      );
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await firebaseService.addHabit(habit);
    } catch (_) {}
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await firebaseService.updateHabit(habit);
    } catch (_) {}
  }

  Future<void> deleteHabit(String id) async {
    try {
      await firebaseService.deleteHabit(id);
    } catch (_) {}
  }
}
