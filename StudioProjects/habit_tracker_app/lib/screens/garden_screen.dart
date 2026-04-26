import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'plant_details_screen.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Habit Garden Builder'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(
                    state.firebaseConnected ? 'Firebase' : 'Mock API',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  avatar: Icon(
                    state.firebaseConnected
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _GardenHeader(
                  habitCount: state.habits.length,
                  message: state.message,
                ),
              ),
              Expanded(
                child: switch (state.status) {
                  HabitStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  HabitStatus.error => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Could not load your garden'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.read<HabitCubit>().loadHabits(),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                  HabitStatus.success => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 220,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: state.habits.length,
                    itemBuilder: (context, index) {
                      final habit = state.habits[index];
                      return HabitCard(
                        habit: habit,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlantDetailsScreen(habitId: habit.id),
                          ),
                        ),
                      );
                    },
                  ),
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen()),
            ),
            label: const Text('Plant New Habit'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _GardenHeader extends StatelessWidget {
  final int habitCount;
  final String? message;

  const _GardenHeader({required this.habitCount, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plants in garden: $habitCount',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(message ?? 'Keep watering habits to evolve every plant stage'),
        ],
      ),
    );
  }
}
