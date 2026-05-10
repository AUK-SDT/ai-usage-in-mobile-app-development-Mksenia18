import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../services/login_memory_service.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginMemoryService = LoginMemoryService();
  List<String> _savedEmails = [];
  String? _selectedEmail;
  String? _pendingEmail;
  String? _pendingPassword;
  bool _rememberPassword = true;

  @override
  void initState() {
    super.initState();
    _restoreSavedAccounts();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.status == AuthStatus.authenticated) {
            final currentEmail =
                _pendingEmail?.trim().toLowerCase() ??
                state.user?.email?.trim().toLowerCase();
            if (currentEmail != null && currentEmail.isNotEmpty) {
              _loginMemoryService.saveAccount(
                email: currentEmail,
                password: _pendingPassword,
                rememberPassword: _rememberPassword,
              );
              _restoreSavedAccounts();
            }
            _pendingEmail = null;
            _pendingPassword = null;
          }
        },
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_savedEmails.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEmail,
                    decoration: const InputDecoration(
                      labelText: 'Recent accounts',
                      border: OutlineInputBorder(),
                    ),
                    items: _savedEmails
                        .map(
                          (email) => DropdownMenuItem(
                            value: email,
                            child: Text(email),
                          ),
                        )
                        .toList(),
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            _applySavedAccount(value);
                          },
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Remember password'),
                  value: _rememberPassword,
                  onChanged: loading
                      ? null
                      : (value) {
                          setState(() => _rememberPassword = value ?? true);
                        },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: loading
                      ? null
                      : () {
                          _pendingEmail = _emailController.text.trim();
                          _pendingPassword = _passwordController.text.trim();
                          context.read<AuthCubit>().signInWithEmail(
                            email: _pendingEmail!,
                            password: _pendingPassword!,
                          );
                        },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => context.read<AuthCubit>().signInWithGoogle(),
                  icon: const Icon(Icons.login),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          ),
                  child: const Text('Create account'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _restoreSavedAccounts() async {
    final savedEmails = await _loginMemoryService.getSavedEmails();
    final lastEmail = await _loginMemoryService.getLastEmail();
    if (!mounted) {
      return;
    }
    setState(() {
      _savedEmails = savedEmails;
      _selectedEmail = savedEmails.contains(lastEmail) ? lastEmail : null;
      if (_selectedEmail != null) {
        _emailController.text = _selectedEmail!;
      }
    });
    if (_selectedEmail != null) {
      await _applySavedAccount(_selectedEmail!);
    }
  }

  Future<void> _applySavedAccount(String email) async {
    final password = await _loginMemoryService.getPassword(email);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedEmail = email;
      _emailController.text = email;
      _passwordController.text = password ?? '';
      _rememberPassword = password != null;
    });
  }
}
