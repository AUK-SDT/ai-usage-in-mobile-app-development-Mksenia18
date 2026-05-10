import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitHistoryScreen extends StatelessWidget {
  final Habit habit;

  const HabitHistoryScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit History')),
      body: habit.completionHistory.isEmpty
          ? const Center(
              child: Text('No completions yet. Finish this habit to build history.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: habit.completionHistory.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final date = habit.completionHistory[index];
                final dateLabel = _formatDate(date);
                final timeLabel = _formatTime(date);
                final completionNumber = habit.completionHistory.length - index;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text('Completion $completionNumber'),
                    subtitle: Text('$dateLabel at $timeLabel'),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
