import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/habit_cubit.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const HabitGardenApp());
}

class HabitGardenApp extends StatelessWidget {
  const HabitGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitCubit()..loadHabits(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Habit Garden',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF4FFF1),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
