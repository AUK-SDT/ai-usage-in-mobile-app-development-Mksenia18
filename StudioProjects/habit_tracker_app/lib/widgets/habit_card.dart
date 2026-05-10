import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/plant_state.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({super.key, required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final plantState = PlantState.fromHabit(habit);
    return Card(
      elevation: plantState.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: habit.isWithering
                  ? [Colors.brown.shade100, Colors.orange.shade200]
                  : [Colors.green.shade50, Colors.green.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: habit.isWithering ? Colors.brown.shade300 : Colors.green.shade300,
            ),
          ),
          child: AnimatedScale(
            scale: plantState.growthScale,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: plantState.saturation,
                  child: Text(plantState.icon, style: const TextStyle(fontSize: 44)),
                ),
                const SizedBox(height: 10),
                Text(
                  habit.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  habit.category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${plantState.stageLabel} • ${plantState.healthLabel}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: habit.xp / 100),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.green.shade50,
                          color: habit.isWithering ? Colors.brown : Colors.green,
                          minHeight: 7,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Health ${habit.health}%',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Week ${habit.completionsThisWeek} done',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
