import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/auth_bloc.dart';
import '../../application/bloc/auth_event.dart';
import '../../application/bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final verificationId = (args?['verificationId'] ?? '') as String;
    final mode = (args?['mode'] ?? 'login') as String;
    final phone = (args?['phone'] ?? '') as String;
    final password = args?['password'] as String?;
    final displayName = args?['displayName'] as String?;
    final newPassword = args?['newPassword'] as String?;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.error != c.error || p.user != c.user,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.user != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/todos', (_) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Verify OTP ($mode)')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: codeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '6-digit code'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final code = codeCtrl.text.trim();
                          context.read<AuthBloc>().add(
                              AuthVerifyOtpRequested(verificationId, code));
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          if (mode == 'signup' && password != null) {
                            context
                                .read<AuthBloc>()
                                .add(AuthSignupWithPasswordRequested(
                                  phone,
                                  password,
                                  displayName: displayName,
                                ));
                          } else if (mode == 'login' && password != null) {
                            context.read<AuthBloc>().add(
                                AuthLoginWithPasswordRequested(
                                    phone, password));
                          } else if (mode == 'reset' && newPassword != null) {
                            context
                                .read<AuthBloc>()
                                .add(AuthResetPasswordWithOtpRequested(
                                  phone,
                                  newPassword,
                                  verificationId,
                                  code,
                                ));
                          }
                        },
                  child: Text(state.isLoading ? 'Verifying...' : 'Verify'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
