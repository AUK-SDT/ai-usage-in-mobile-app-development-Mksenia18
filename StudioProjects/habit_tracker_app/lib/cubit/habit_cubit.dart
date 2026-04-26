import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitRepository _repository;

  HabitCubit({HabitRepository? repository})
    : _repository = repository ?? HabitRepository(),
      super(const HabitState());

  void loadHabits() async {
    emit(state.copyWith(status: HabitStatus.loading, message: null));
    try {
      final result = await _repository.fetchHabits();
      emit(
        state.copyWith(
          status: HabitStatus.success,
          habits: result.habits,
          firebaseConnected: result.firebaseConnected,
          message: result.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HabitStatus.error,
          message: 'Could not load habits',
        ),
      );
    }
  }

  void completeHabit(String id) async {
    if (state.status != HabitStatus.success) {
      return;
    }
    final updatedHabits = state.habits.map((habit) {
      if (habit.id != id) {
        return habit;
      }
      final updatedXp = habit.xp + 25;
      var nextLevel = habit.level;
      var nextXp = updatedXp;
      if (updatedXp >= 100 && habit.level < 4) {
        nextLevel = habit.level + 1;
        nextXp = updatedXp - 100;
      }
      return habit.copyWith(
        level: nextLevel,
        xp: nextXp.clamp(0, 100),
        health: (habit.health + 3).clamp(0, 100),
        completionsThisWeek: habit.completionsThisWeek + 1,
        currentStreak: habit.currentStreak + 1,
      );
    }).toList();
    emit(state.copyWith(habits: updatedHabits, status: HabitStatus.success));
    final updatedHabit = updatedHabits.firstWhere((habit) => habit.id == id);
    await _repository.updateHabit(updatedHabit);
  }

  void addHabit(String title, String category) async {
    if (state.status != HabitStatus.success) {
      return;
    }
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      level: 1,
      xp: 0,
      health: 100,
    );
    await _repository.addHabit(newHabit);
    emit(state.copyWith(habits: [...state.habits, newHabit]));
  }

  void editHabit({
    required String id,
    required String title,
    required String category,
  }) async {
    if (state.status != HabitStatus.success) {
      return;
    }
    final updatedHabits = state.habits.map((habit) {
      if (habit.id != id) {
        return habit;
      }
      return habit.copyWith(title: title, category: category);
    }).toList();
    emit(state.copyWith(habits: updatedHabits));
    final updatedHabit = updatedHabits.firstWhere((habit) => habit.id == id);
    await _repository.updateHabit(updatedHabit);
  }

  void deleteHabit(String id) async {
    if (state.status != HabitStatus.success) {
      return;
    }
    final updatedHabits = state.habits
        .where((habit) => habit.id != id)
        .toList();
    emit(state.copyWith(habits: updatedHabits));
    await _repository.deleteHabit(id);
  }
}
