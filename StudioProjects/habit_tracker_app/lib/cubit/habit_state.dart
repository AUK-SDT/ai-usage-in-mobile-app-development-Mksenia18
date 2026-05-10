import '../models/habit.dart';

enum HabitStatus { loading, success, error }
enum HabitOperationStatus { idle, inProgress }

const _unset = Object();

class HabitState {
  final HabitStatus status;
  final HabitOperationStatus operationStatus;
  final List<Habit> habits;
  final String? infoMessage;
  final String? errorMessage;
  final bool firebaseConnected;

  const HabitState({
    this.status = HabitStatus.loading,
    this.operationStatus = HabitOperationStatus.idle,
    this.habits = const [],
    this.infoMessage,
    this.errorMessage,
    this.firebaseConnected = false,
  });

  HabitState copyWith({
    HabitStatus? status,
    HabitOperationStatus? operationStatus,
    List<Habit>? habits,
    Object? infoMessage = _unset,
    Object? errorMessage = _unset,
    bool? firebaseConnected,
  }) {
    return HabitState(
      status: status ?? this.status,
      operationStatus: operationStatus ?? this.operationStatus,
      habits: habits ?? this.habits,
      infoMessage: identical(infoMessage, _unset)
          ? this.infoMessage
          : infoMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      firebaseConnected: firebaseConnected ?? this.firebaseConnected,
    );
  }
}
