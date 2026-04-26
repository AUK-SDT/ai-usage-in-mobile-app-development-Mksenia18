import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';
import 'statistics_screen.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        if (state.status != HabitStatus.success) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final weeklyCompletions = state.habits.fold<int>(
          0,
          (sum, habit) => sum + habit.completionsThisWeek,
        );
        final bestStreak = state.habits.fold<int>(
          0,
          (best, habit) =>
              habit.currentStreak > best ? habit.currentStreak : best,
        );
        final averageHealth = state.habits.isEmpty
            ? 0
            : state.habits.fold<int>(0, (sum, habit) => sum + habit.health) ~/
                  state.habits.length;
        final mission1Done = weeklyCompletions >= 5;
        final mission2Done = bestStreak >= 3;
        final mission3Done = averageHealth >= 90;
        final allDone = mission1Done && mission2Done && mission3Done;

        return Scaffold(
          appBar: AppBar(title: const Text('Weekly Missions')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MissionTile(
                title: 'Complete any habit 5 times',
                progress: '${weeklyCompletions.clamp(0, 5)} / 5',
                reward: '+120 XP',
                isDone: mission1Done,
              ),
              _MissionTile(
                title: 'Reach a 3-day streak',
                progress: '${bestStreak.clamp(0, 3)} / 3',
                reward: 'Unlock new planter',
                isDone: mission2Done,
              ),
              _MissionTile(
                title: 'Keep garden health above 90%',
                progress: '$averageHealth%',
                reward: 'Seasonal theme',
                isDone: mission3Done,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: allDone
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rewards claimed')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  allDone ? 'Claim Rewards' : 'Complete missions first',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Open Stats'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissionTile extends StatelessWidget {
  final String title;
  final String progress;
  final String reward;
  final bool isDone;

  const _MissionTile({
    required this.title,
    required this.progress,
    required this.reward,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(isDone ? Icons.check : Icons.emoji_events_outlined),
        ),
        title: Text(title),
        subtitle: Text('Progress: $progress'),
        trailing: Text(
          reward,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
