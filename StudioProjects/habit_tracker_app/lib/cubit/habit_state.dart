import '../models/habit.dart';

enum HabitStatus { loading, success, error }

class HabitState {
  final HabitStatus status;
  final List<Habit> habits;
  final String? message;
  final bool firebaseConnected;

  const HabitState({
    this.status = HabitStatus.loading,
    this.habits = const [],
    this.message,
    this.firebaseConnected = false,
  });

  HabitState copyWith({
    HabitStatus? status,
    List<Habit>? habits,
    String? message,
    bool? firebaseConnected,
  }) {
    return HabitState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      message: message,
      firebaseConnected: firebaseConnected ?? this.firebaseConnected,
    );
  }
}
