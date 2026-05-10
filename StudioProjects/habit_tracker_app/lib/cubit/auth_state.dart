import '../models/app_user.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated, error }

const _authUnset = Object();

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _authUnset,
    Object? errorMessage = _authUnset,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: identical(user, _authUnset) ? this.user : user as AppUser?,
      errorMessage: identical(errorMessage, _authUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
