import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/habit_constants.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _controller = TextEditingController();
  String _selectedCategory = habitCategories.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant New Habit')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: habitCategories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _controller.text.trim();
                  if (title.isNotEmpty) {
                    final added = await context.read<HabitCubit>().addHabit(
                      title,
                      _selectedCategory,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    if (!added) {
                      final error = context.read<HabitCubit>().state.errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Could not add habit'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                  }
                },
                child: BlocBuilder<HabitCubit, HabitState>(
                  buildWhen: (previous, current) =>
                      previous.operationStatus != current.operationStatus,
                  builder: (context, state) {
                    if (state.operationStatus == HabitOperationStatus.inProgress) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return const Text('Plant in Garden');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
