import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';
import '../models/mission.dart';
import 'statistics_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        if (state.status == HabitStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == HabitStatus.error) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Weekly Missions'),
              actions: [
                IconButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign out',
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.errorMessage ?? 'Could not load missions',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (state.habits.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Weekly Missions'),
              actions: [
                IconButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign out',
                ),
              ],
            ),
            body: const Center(
              child: Text('No missions yet. Add habits first.'),
            ),
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
        final completionMission = _resolveMission(
          value: weeklyCompletions,
          levels: const [
            MissionLevel(
              title: 'Complete any habit 5 times',
              reward: '+120 XP',
              target: 5,
            ),
            MissionLevel(
              title: 'Complete any habit 10 times',
              reward: '+250 XP',
              target: 10,
            ),
            MissionLevel(
              title: 'Complete any habit 20 times',
              reward: '+500 XP + booster',
              target: 20,
            ),
          ],
          unitSuffix: '',
          endlessStep: 10,
          endlessTitleBuilder: (target) => 'Complete any habit $target times',
          endlessRewardBuilder: (target) => '+${target * 30} XP',
        );
        final streakMission = _resolveMission(
          value: bestStreak,
          levels: const [
            MissionLevel(
              title: 'Reach a 3-day streak',
              reward: 'Unlock new planter',
              target: 3,
            ),
            MissionLevel(
              title: 'Reach a 5-day streak',
              reward: 'Rare planter variant',
              target: 5,
            ),
            MissionLevel(
              title: 'Reach a 7-day streak',
              reward: 'Legendary streak aura',
              target: 7,
            ),
          ],
          unitSuffix: '',
          endlessStep: 2,
          endlessTitleBuilder: (target) => 'Reach a $target-day streak',
          endlessRewardBuilder: (target) => 'Streak boost x$target',
        );
        final healthMission = _resolveMission(
          value: averageHealth,
          levels: const [
            MissionLevel(
              title: 'Keep garden health above 90%',
              reward: 'Seasonal theme',
              target: 90,
            ),
            MissionLevel(
              title: 'Keep garden health above 95%',
              reward: 'Golden leaves skin',
              target: 95,
            ),
            MissionLevel(
              title: 'Keep garden health above 98%',
              reward: 'Mythic garden frame',
              target: 98,
            ),
          ],
          unitSuffix: '%',
          endlessStep: 1,
          endlessTitleBuilder: (target) => 'Keep garden health above $target%',
          endlessRewardBuilder: (target) => 'Aura level ${target - 90}',
        );
        final flameProgress = _calculateFlameProgress(
          completionMission: completionMission,
          streakMission: streakMission,
          healthMission: healthMission,
        );
        final flameLevel = (flameProgress * 5).clamp(0, 5).round();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Weekly Missions'),
            actions: [
              IconButton(
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MissionTile(
                title: completionMission.title,
                progress: completionMission.progressLabel,
                reward: completionMission.reward,
                isDone: completionMission.isDone,
              ),
              _MissionTile(
                title: streakMission.title,
                progress: streakMission.progressLabel,
                reward: streakMission.reward,
                isDone: streakMission.isDone,
              ),
              _MissionTile(
                title: healthMission.title,
                progress: healthMission.progressLabel,
                reward: healthMission.reward,
                isDone: healthMission.isDone,
              ),
              const SizedBox(height: 12),
              _FlameProgressCard(
                progress: flameProgress,
                flameLevel: flameLevel,
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

  double _calculateFlameProgress({
    required Mission completionMission,
    required Mission streakMission,
    required Mission healthMission,
  }) {
    final completionRatio = completionMission.target == 0
        ? 0.0
        : completionMission.current / completionMission.target;
    final streakRatio = streakMission.target == 0
        ? 0.0
        : streakMission.current / streakMission.target;
    final healthRatio = healthMission.target == 0
        ? 0.0
        : healthMission.current / healthMission.target;

    final weighted = (completionRatio * 0.4) + (streakRatio * 0.3) + (healthRatio * 0.3);
    return weighted.clamp(0.0, 1.0);
  }

  Mission _resolveMission({
    required int value,
    required List<MissionLevel> levels,
    required String unitSuffix,
    required int endlessStep,
    required String Function(int target) endlessTitleBuilder,
    required String Function(int target) endlessRewardBuilder,
  }) {
    return MissionFactory.fromValue(
      value: value,
      levels: levels,
      unitSuffix: unitSuffix,
      endlessStep: endlessStep,
      endlessTitleBuilder: endlessTitleBuilder,
      endlessRewardBuilder: endlessRewardBuilder,
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

class _FlameProgressCard extends StatelessWidget {
  final double progress;
  final int flameLevel;

  const _FlameProgressCard({
    required this.progress,
    required this.flameLevel,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final flameSize = 28 + (progress * 28);
    final statusLabel = switch (flameLevel) {
      0 => 'Spark just started',
      1 => 'Warm up',
      2 => 'Steady flame',
      3 => 'On fire',
      4 => 'Blazing',
      _ => 'Legendary fire',
    };

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 24, end: flameSize),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Text(
                    '🔥',
                    style: TextStyle(fontSize: value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mission Fire Level $flameLevel',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: Colors.deepOrange,
                backgroundColor: Colors.orange.shade100,
              ),
            ),
            const SizedBox(height: 8),
            Text(statusLabel),
          ],
        ),
      ),
    );
  }
}
