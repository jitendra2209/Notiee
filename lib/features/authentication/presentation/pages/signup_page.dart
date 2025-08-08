import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/auth_bloc.dart';
import '../../application/bloc/auth_event.dart';
import '../../application/bloc/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final phoneCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.isOtpSent != c.isOtpSent || p.error != c.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.isOtpSent) {
          Navigator.pushNamed(context, '/otp', arguments: {
            'verificationId': state.verificationId,
            'phone': phoneCtrl.text.trim(),
            'mode': 'signup',
            'password': pwdCtrl.text,
            'displayName': nameCtrl.text.trim(),
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign up')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Phone (+91XXXXXXXXXX)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final phone = phoneCtrl.text.trim();
                            context
                                .read<AuthBloc>()
                                .add(AuthSendOtpRequested(phone));
                          },
                    child:
                        Text(state.isLoading ? 'Sending OTP...' : 'Send OTP'),
                  );
                },
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
