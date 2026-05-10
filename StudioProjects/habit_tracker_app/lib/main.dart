import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/habit_cubit.dart';
import 'repositories/habit_repository.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }
  runApp(HabitGardenApp(firebaseReady: firebaseReady));
}

class HabitGardenApp extends StatelessWidget {
  final bool firebaseReady;

  const HabitGardenApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Habit Garden',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF4FFF1),
        ),
        home: const _FirebaseSetupScreen(),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(
          create: (_) => HabitCubit(
            repository: HabitRepository(allowMockFallback: false),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Habit Garden',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF4FFF1),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Setup Required')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase is not initialized for this app.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text('To run Auth + Realtime features:'),
            SizedBox(height: 8),
            Text('1. Run `flutterfire configure`'),
            Text('2. Add platform config files from Firebase Console'),
            Text('3. Restart the app'),
          ],
        ),
      ),
    );
  }
}
