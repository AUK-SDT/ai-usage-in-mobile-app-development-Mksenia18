import '../models/habit.dart';
import '../services/firebase_habit_service.dart';
import '../services/mock_habit_service.dart';

class HabitRepositoryException implements Exception {
  final String message;

  const HabitRepositoryException(this.message);

  @override
  String toString() => message;
}

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
  final bool allowMockFallback;
  String? _currentUserId;

  HabitRepository({
    FirebaseHabitService? firebaseService,
    MockHabitService? mockService,
    this.allowMockFallback = false,
  }) : firebaseService = firebaseService ?? FirebaseHabitService(),
       mockService = mockService ?? MockHabitService();

  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  Stream<HabitRepositoryResult> watchHabits() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      return Stream.value(
        const HabitRepositoryResult(
          habits: [],
          firebaseConnected: false,
          message: 'Please sign in to see habits',
        ),
      );
    }
    try {
      return firebaseService.watchHabits(userId).map((habits) {
        return HabitRepositoryResult(habits: habits, firebaseConnected: true);
      });
    } catch (error) {
      if (!allowMockFallback) {
        return Stream.error(HabitRepositoryException(_mapErrorToMessage(error)));
      }
      return Stream.fromFuture(mockService.fetchHabits()).map((fallbackHabits) {
        return HabitRepositoryResult(
          habits: fallbackHabits,
          firebaseConnected: false,
          message: 'Using offline demo data',
        );
      });
    }
  }

  Future<HabitRepositoryResult> fetchHabits() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      return const HabitRepositoryResult(
        habits: [],
        firebaseConnected: false,
        message: 'Please sign in to see habits',
      );
    }
    try {
      final habits = await firebaseService.watchHabits(userId).first;
      return HabitRepositoryResult(habits: habits, firebaseConnected: true);
    } catch (error) {
      if (!allowMockFallback) {
        throw HabitRepositoryException(_mapErrorToMessage(error));
      }
      final fallbackHabits = await mockService.fetchHabits();
      return HabitRepositoryResult(
        habits: fallbackHabits,
        firebaseConnected: false,
        message: 'Using offline demo data',
      );
    }
  }

  Future<void> addHabit(Habit habit) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw const HabitRepositoryException('Please sign in first');
    }
    try {
      await firebaseService.addHabit(userId: userId, habit: habit);
    } catch (error) {
      if (allowMockFallback) {
        return;
      }
      throw HabitRepositoryException(_mapErrorToMessage(error));
    }
  }

  Future<void> updateHabit(Habit habit) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw const HabitRepositoryException('Please sign in first');
    }
    try {
      await firebaseService.updateHabit(userId: userId, habit: habit);
    } catch (error) {
      if (allowMockFallback) {
        return;
      }
      throw HabitRepositoryException(_mapErrorToMessage(error));
    }
  }

  Future<void> deleteHabit(String id) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw const HabitRepositoryException('Please sign in first');
    }
    try {
      await firebaseService.deleteHabit(userId: userId, id: id);
    } catch (error) {
      if (allowMockFallback) {
        return;
      }
      throw HabitRepositoryException(_mapErrorToMessage(error));
    }
  }

  String _mapErrorToMessage(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('failed-precondition') ||
        raw.contains('permission denied')) {
      return 'Firebase is not configured for this app yet';
    }
    if (raw.contains('permission-denied')) {
      return 'Permission denied while accessing habits';
    }
    if (raw.contains('unavailable') || raw.contains('network')) {
      return 'Network is unavailable. Please try again';
    }
    if (raw.contains('not-found')) {
      return 'Habit does not exist anymore';
    }
    return 'Unexpected data error occurred';
  }
}
