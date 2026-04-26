import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({super.key, required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(habit.plantIcon, style: const TextStyle(fontSize: 40)),
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
              habit.stageLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: habit.xp / 100,
                  backgroundColor: Colors.green.shade50,
                  color: Colors.green,
                  minHeight: 6,
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
    );
  }
}
