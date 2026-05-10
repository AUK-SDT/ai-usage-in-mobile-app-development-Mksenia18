import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firebase_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthService _authService;
  StreamSubscription? _authSubscription;

  AuthCubit({FirebaseAuthService? authService})
    : _authService = authService ?? FirebaseAuthService(),
      super(const AuthState()) {
    _authSubscription = _authService.authStateChanges().listen((user) {
      if (user == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            errorMessage: null,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ),
      );
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authService.signInWithEmail(email: email, password: password);
    } on AuthServiceException catch (error) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: 'Could not sign in'),
      );
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authService.signUpWithEmail(email: email, password: password);
    } on AuthServiceException catch (error) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Could not create account',
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authService.signInWithGoogle();
    } on AuthServiceException catch (error) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Could not sign in with Google',
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authService.signOut();
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Could not sign out'));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
