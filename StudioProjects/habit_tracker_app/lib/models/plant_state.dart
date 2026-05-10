import 'habit.dart';

class PlantState {
  final String icon;
  final String stageLabel;
  final String healthLabel;
  final double growthScale;
  final double cardElevation;
  final double saturation;

  const PlantState({
    required this.icon,
    required this.stageLabel,
    required this.healthLabel,
    required this.growthScale,
    required this.cardElevation,
    required this.saturation,
  });

  factory PlantState.fromHabit(Habit habit) {
    final xpPulse = (habit.xp / 100) * 0.04;
    final healthPenalty = habit.isWithering ? 0.03 : 0.0;
    final scale = (0.94 + (habit.level * 0.035) + xpPulse - healthPenalty).clamp(
      0.88,
      1.12,
    );
    final elevation = habit.isWithering ? 1.0 : 4.0;
    final saturation = habit.isWithering ? 0.55 : 1.0;
    final healthLabel = habit.isWithering
        ? 'Withering'
        : habit.isHealthy
        ? 'Healthy'
        : 'Needs care';
    return PlantState(
      icon: habit.plantIcon,
      stageLabel: habit.stageLabel,
      healthLabel: healthLabel,
      growthScale: scale,
      cardElevation: elevation,
      saturation: saturation,
    );
  }
}
