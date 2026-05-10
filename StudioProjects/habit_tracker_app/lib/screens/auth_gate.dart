import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../cubit/habit_cubit.dart';
import 'home_shell.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastBoundUserId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        final userId = state.user?.uid;
        if (_lastBoundUserId == userId) {
          return;
        }
        _lastBoundUserId = userId;
        context.read<HabitCubit>().bindUser(userId);
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            return const HomeShell();
          case AuthStatus.error:
          case AuthStatus.unauthenticated:
            return const SignInScreen();
        }
      },
    );
  }
}
