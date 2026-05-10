import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/cubit/auth_state.dart';
import 'package:habit_tracker_app/models/app_user.dart';

void main() {
  test('AuthState copyWith updates status and user', () {
    const base = AuthState(status: AuthStatus.unknown);
    const user = AppUser(uid: 'u1', email: 'demo@mail.com');

    final updated = base.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      errorMessage: null,
    );

    expect(updated.status, AuthStatus.authenticated);
    expect(updated.user?.uid, 'u1');
    expect(updated.errorMessage, isNull);
  });
}
