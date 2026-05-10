import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/habit_state.dart';
import '../cubit/habit_cubit.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocBuilder<HabitCubit, HabitState>(
        builder: (context, state) {
          if (state.status == HabitStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HabitStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.errorMessage ?? 'Could not load statistics',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state.habits.isEmpty) {
            return const Center(
              child: Text('Add habits to unlock statistics'),
            );
          }

          final totalHabits = state.habits.length;
          final totalCompletions = state.habits.fold<int>(
            0,
            (sum, habit) => sum + habit.completionsThisWeek,
          );
          final averageHealth = totalHabits == 0
              ? 0
              : state.habits.fold<int>(0, (sum, habit) => sum + habit.health) ~/
                    totalHabits;
          final trees = state.habits.where((habit) => habit.level == 4).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatTile(
                title: 'Weekly completions',
                value: '$totalCompletions',
                icon: Icons.check_circle_outline,
              ),
              _StatTile(
                title: 'Average garden health',
                value: '$averageHealth%',
                icon: Icons.favorite_outline,
              ),
              _StatTile(
                title: 'Fully grown trees',
                value: '$trees',
                icon: Icons.park_outlined,
              ),
              _StatTile(
                title: 'Tracked habits',
                value: '$totalHabits',
                icon: Icons.local_florist_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
