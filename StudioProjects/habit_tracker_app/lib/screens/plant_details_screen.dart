import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String habitId;
  const PlantDetailsScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Details')),
      body: BlocBuilder<HabitCubit, HabitState>(
        builder: (context, state) {
          if (state.status != HabitStatus.success) {
            return const Center(child: CircularProgressIndicator());
          }
          final habit = state.habits.firstWhere((h) => h.id == habitId);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          habit.plantIcon,
                          style: const TextStyle(fontSize: 84),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          habit.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text('Category: ${habit.category}'),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: habit.xp / 100,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Stage: ${habit.stageLabel}  •  Health: ${habit.health}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<HabitCubit>().completeHabit(habit.id),
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Complete Habit'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('View History (coming soon)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showEditHabitDialog(context, habit.id),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Habit'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    context.read<HabitCubit>().deleteHabit(habit.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Habit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditHabitDialog(BuildContext context, String id) {
    final cubit = context.read<HabitCubit>();
    final state = cubit.state;
    if (state.status != HabitStatus.success) {
      return;
    }
    final habit = state.habits.firstWhere((item) => item.id == id);
    final titleController = TextEditingController(text: habit.title);
    var selectedCategory = habit.category;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Habit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: ['Health', 'Study', 'Fitness', 'Mindset', 'Work']
                        .map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() => selectedCategory = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      return;
                    }
                    cubit.editHabit(
                      id: id,
                      title: title,
                      category: selectedCategory,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
