import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/habit_cubit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _controller = TextEditingController();
  String _selectedCategory = 'Health';

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
              items: ['Health', 'Study', 'Fitness', 'Mindset', 'Work'].map((
                cat,
              ) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.notifications_none),
              label: const Text('Reminder Time (beta preview)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    context.read<HabitCubit>().addHabit(
                      _controller.text,
                      _selectedCategory,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Plant in Garden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
