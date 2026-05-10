import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/cubit/habit_cubit.dart';
import 'package:habit_tracker_app/cubit/habit_state.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/repositories/habit_repository.dart';

class FakeHabitRepository extends HabitRepository {
  FakeHabitRepository({
    this.fetchResult,
    this.fetchError,
    this.writeError,
  });

  final HabitRepositoryResult? fetchResult;
  final String? fetchError;
  final String? writeError;

  @override
  Future<HabitRepositoryResult> fetchHabits() async {
    if (fetchError != null) {
      throw HabitRepositoryException(fetchError!);
    }
    return fetchResult ??
        const HabitRepositoryResult(habits: [], firebaseConnected: true);
  }

  @override
  Future<void> addHabit(Habit habit) async {
    if (writeError != null) {
      throw HabitRepositoryException(writeError!);
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    if (writeError != null) {
      throw HabitRepositoryException(writeError!);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    if (writeError != null) {
      throw HabitRepositoryException(writeError!);
    }
  }
}

void main() {
  group('HabitCubit', () {
    test('loadHabits emits success with fetched habits', () async {
      final cubit = HabitCubit(
        repository: FakeHabitRepository(
          fetchResult: HabitRepositoryResult(
            habits: [
              Habit(id: '1', title: 'Drink Water', category: 'Health'),
            ],
            firebaseConnected: true,
          ),
        ),
      );

      await cubit.loadHabits();

      expect(cubit.state.status, HabitStatus.success);
      expect(cubit.state.habits.length, 1);
      expect(cubit.state.errorMessage, isNull);
    });

    test('loadHabits emits error when repository fails', () async {
      final cubit = HabitCubit(
        repository: FakeHabitRepository(fetchError: 'Network is unavailable'),
      );

      await cubit.loadHabits();

      expect(cubit.state.status, HabitStatus.error);
      expect(cubit.state.errorMessage, 'Network is unavailable');
    });

    test('addHabit returns false on write failure', () async {
      final cubit = HabitCubit(
        repository: FakeHabitRepository(writeError: 'Permission denied'),
      );

      await cubit.loadHabits();
      final added = await cubit.addHabit('Read Book', 'Study');

      expect(added, false);
      expect(cubit.state.errorMessage, 'Permission denied');
    });
  });
}
