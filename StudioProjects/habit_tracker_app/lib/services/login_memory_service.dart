import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMemoryService {
  static const _savedEmailsKey = 'saved_login_emails';
  static const _lastEmailKey = 'last_login_email';
  static const _secureStorage = FlutterSecureStorage();

  Future<List<String>> getSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedEmailsKey) ?? <String>[];
  }

  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEmailKey);
  }

  Future<void> saveAccount({
    required String email,
    String? password,
    required bool rememberPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList(_savedEmailsKey) ?? <String>[];
    if (!emails.contains(normalizedEmail)) {
      emails.insert(0, normalizedEmail);
    } else {
      emails.remove(normalizedEmail);
      emails.insert(0, normalizedEmail);
    }
    await prefs.setStringList(_savedEmailsKey, emails.take(5).toList());
    await prefs.setString(_lastEmailKey, normalizedEmail);

    final passwordKey = _passwordKey(normalizedEmail);
    if (rememberPassword && password != null && password.isNotEmpty) {
      await _secureStorage.write(key: passwordKey, value: password);
      return;
    }
    await _secureStorage.delete(key: passwordKey);
  }

  Future<String?> getPassword(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return null;
    }
    return _secureStorage.read(key: _passwordKey(normalizedEmail));
  }

  String _passwordKey(String email) => 'saved_password_$email';
}
