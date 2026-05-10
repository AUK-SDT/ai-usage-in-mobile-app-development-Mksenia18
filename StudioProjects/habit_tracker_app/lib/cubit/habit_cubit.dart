import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitRepository _repository;
  StreamSubscription<HabitRepositoryResult>? _habitsSubscription;
  bool _witheringSyncInProgress = false;

  HabitCubit({HabitRepository? repository})
    : _repository = repository ?? HabitRepository(),
      super(const HabitState());

  Future<void> bindUser(String? userId) async {
    await _habitsSubscription?.cancel();
    _repository.setUserId(userId);
    emit(
      state.copyWith(
        status: HabitStatus.loading,
        habits: [],
        infoMessage: null,
        errorMessage: null,
      ),
    );
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: HabitStatus.success,
          habits: [],
          infoMessage: 'Sign in to start your garden',
          firebaseConnected: false,
        ),
      );
      return;
    }
    _habitsSubscription = _repository.watchHabits().listen(
      (result) {
        final processedHabits = _applyWithering(result.habits);
        _syncWitheredHabits(result.habits, processedHabits);
        emit(
          state.copyWith(
            status: HabitStatus.success,
            operationStatus: HabitOperationStatus.idle,
            habits: processedHabits,
            firebaseConnected: result.firebaseConnected,
            infoMessage: result.message,
            errorMessage: null,
          ),
        );
      },
      onError: (error) {
        if (error is HabitRepositoryException) {
          emit(state.copyWith(status: HabitStatus.error, errorMessage: error.message));
          return;
        }
        emit(
          state.copyWith(
            status: HabitStatus.error,
            errorMessage: 'Could not load habits',
          ),
        );
      },
    );
  }

  Future<void> loadHabits() async {
    emit(
      state.copyWith(
        status: HabitStatus.loading,
        infoMessage: null,
        errorMessage: null,
      ),
    );
    try {
      final result = await _repository.fetchHabits();
      emit(
        state.copyWith(
          status: HabitStatus.success,
          habits: result.habits,
          firebaseConnected: result.firebaseConnected,
          infoMessage: result.message,
          errorMessage: null,
        ),
      );
    } on HabitRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: HabitStatus.error,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HabitStatus.error,
          errorMessage: 'Could not load habits',
        ),
      );
    }
  }

  Future<bool> completeHabit(String id) async {
    if (state.status != HabitStatus.success) {
      return false;
    }
    final updatedHabit = state.habits.firstWhere(
      (habit) => habit.id == id,
      orElse: () => Habit(id: '', title: '', category: ''),
    );
    if (updatedHabit.id.isEmpty) {
      return false;
    }
    final leveledUpHabit = _applyCompletion(updatedHabit);
    emit(
      state.copyWith(
        operationStatus: HabitOperationStatus.inProgress,
        errorMessage: null,
      ),
    );
    try {
      await _repository.updateHabit(leveledUpHabit);
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          infoMessage: 'Progress saved',
        ),
      );
      return true;
    } on HabitRepositoryException catch (error) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: 'Could not complete habit',
        ),
      );
      return false;
    }
  }

  Future<bool> addHabit(String title, String category) async {
    if (state.status != HabitStatus.success) {
      return false;
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      emit(state.copyWith(errorMessage: 'Habit name cannot be empty'));
      return false;
    }
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmedTitle,
      category: category,
      level: 1,
      xp: 0,
      health: 100,
    );
    emit(
      state.copyWith(
        operationStatus: HabitOperationStatus.inProgress,
        errorMessage: null,
      ),
    );
    try {
      await _repository.addHabit(newHabit);
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          infoMessage: 'Habit added to your garden',
        ),
      );
      return true;
    } on HabitRepositoryException catch (error) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: 'Could not add habit',
        ),
      );
      return false;
    }
  }

  Future<bool> editHabit({
    required String id,
    required String title,
    required String category,
  }) async {
    if (state.status != HabitStatus.success) {
      return false;
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      emit(state.copyWith(errorMessage: 'Habit name cannot be empty'));
      return false;
    }
    final updatedHabits = state.habits.map((habit) {
      if (habit.id != id) {
        return habit;
      }
      return habit.copyWith(title: trimmedTitle, category: category);
    }).toList();
    final updatedHabit = updatedHabits.firstWhere((habit) => habit.id == id);
    emit(
      state.copyWith(
        operationStatus: HabitOperationStatus.inProgress,
        errorMessage: null,
      ),
    );
    try {
      await _repository.updateHabit(updatedHabit);
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          infoMessage: 'Habit updated',
        ),
      );
      return true;
    } on HabitRepositoryException catch (error) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: 'Could not edit habit',
        ),
      );
      return false;
    }
  }

  Future<bool> deleteHabit(String id) async {
    if (state.status != HabitStatus.success) {
      return false;
    }
    emit(
      state.copyWith(
        operationStatus: HabitOperationStatus.inProgress,
        errorMessage: null,
      ),
    );
    try {
      await _repository.deleteHabit(id);
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          infoMessage: 'Habit removed from garden',
        ),
      );
      return true;
    } on HabitRepositoryException catch (error) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          operationStatus: HabitOperationStatus.idle,
          errorMessage: 'Could not delete habit',
        ),
      );
      return false;
    }
  }

  Habit _applyCompletion(Habit habit) {
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
      completionHistory: [DateTime.now(), ...habit.completionHistory],
      lastWitherAt: DateTime.now(),
    );
  }

  List<Habit> _applyWithering(List<Habit> habits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return habits.map((habit) {
      final baseline = _latestDate([
        habit.createdAt,
        habit.lastCompletionAt,
        habit.lastWitherAt,
      ]);
      final baselineDay = DateTime(baseline.year, baseline.month, baseline.day);
      final missedDays = today.difference(baselineDay).inDays;
      if (missedDays <= 0) {
        return habit;
      }
      final decay = missedDays * 5;
      final nextHealth = (habit.health - decay).clamp(0, 100);
      if (nextHealth == habit.health) {
        return habit;
      }
      return habit.copyWith(
        health: nextHealth,
        currentStreak: 0,
        lastWitherAt: now,
      );
    }).toList();
  }

  DateTime _latestDate(List<DateTime?> values) {
    var latest = DateTime.fromMillisecondsSinceEpoch(0);
    for (final value in values) {
      if (value != null && value.isAfter(latest)) {
        latest = value;
      }
    }
    return latest;
  }

  void _syncWitheredHabits(List<Habit> original, List<Habit> processed) {
    if (_witheringSyncInProgress) {
      return;
    }
    final changed = <Habit>[];
    for (var i = 0; i < original.length && i < processed.length; i++) {
      final before = original[i];
      final after = processed[i];
      if (before.health != after.health || before.lastWitherAt != after.lastWitherAt) {
        changed.add(after);
      }
    }
    if (changed.isEmpty) {
      return;
    }
    _witheringSyncInProgress = true;
    () async {
      try {
        for (final habit in changed) {
          await _repository.updateHabit(habit);
        }
      } finally {
        _witheringSyncInProgress = false;
      }
    }();
  }

  @override
  Future<void> close() async {
    await _habitsSubscription?.cancel();
    return super.close();
  }
}
