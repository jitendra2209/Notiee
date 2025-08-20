import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../application/bloc/auth_bloc.dart';
import '../application/bloc/auth_event.dart';
import '../application/bloc/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final phoneCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    phoneCtrl.dispose();
    nameCtrl.dispose();
    pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.error != c.error || p.user != c.user,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.user != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    'assets/logo/logo_svg.svg',
                    height: 230,
                    width: 200,
                    color: Colors.redAccent.shade100,
                  ),
                  Text(
                    'Join us!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: '+91XXXXXXXXXX',
                      prefixIcon: Icon(
                        Icons.phone_rounded,
                        color: Colors.redAccent.shade100,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.redAccent.shade100,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        color: Colors.redAccent.shade100,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.redAccent.shade100,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pwdCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock_rounded,
                        color: Colors.redAccent.shade100,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.redAccent.shade100,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _submit(context),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              state.isLoading ? null : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade100,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Have an account?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.redAccent.shade100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final phone = phoneCtrl.text.trim();
    context.read<AuthBloc>().add(
          AuthSignupWithPasswordRequested(
            phone,
            pwdCtrl.text,
            displayName: nameCtrl.text.trim(),
          ),
        );
  }
}
