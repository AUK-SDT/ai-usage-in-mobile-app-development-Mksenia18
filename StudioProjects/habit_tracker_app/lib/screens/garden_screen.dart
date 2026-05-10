import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
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
              IconButton(
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _GardenHeader(
                  habitCount: state.habits.length,
                  infoMessage: state.infoMessage,
                  errorMessage: state.errorMessage,
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
                        Text(
                          state.errorMessage ?? 'Could not load your garden',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.read<HabitCubit>().loadHabits(),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                  HabitStatus.success => state.habits.isEmpty
                      ? _EmptyGarden(
                          onAddPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddHabitScreen(),
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            GridView.builder(
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
                                      builder: (_) => PlantDetailsScreen(
                                        habitId: habit.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (state.operationStatus ==
                                HabitOperationStatus.inProgress)
                              const _OperationOverlay(),
                          ],
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
  final String? infoMessage;
  final String? errorMessage;

  const _GardenHeader({
    required this.habitCount,
    required this.infoMessage,
    required this.errorMessage,
  });

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
          Text(
            errorMessage ??
                infoMessage ??
                'Keep watering habits to evolve every plant stage',
          ),
        ],
      ),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyGarden({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_florist_outlined, size: 56),
            const SizedBox(height: 12),
            const Text(
              'No habits yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plant your first habit and start growing your garden',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add First Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationOverlay extends StatelessWidget {
  const _OperationOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
